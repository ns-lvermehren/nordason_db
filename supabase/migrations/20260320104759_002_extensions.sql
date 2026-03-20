create extension if not exists pg_trgm  schema extensions;
create extension if not exists unaccent schema extensions;

create or replace function norm(t text)
returns text as $$
  select lower(extensions.unaccent(regexp_replace(trim(t), '\s+', ' ', 'g')))
$$ language sql immutable;

create index if not exists idx_pm_name_trgm
  on product_master using gin (norm(name) extensions.gin_trgm_ops);

create index if not exists idx_pm_type
  on product_master (article_type);

create or replace function fuzzy_match_artikel(
    suchbegriff    text,
    p_article_type text    default null,
    limit_n        int     default 5,
    min_score      float   default 0.25
)
returns table (
    internal_reference text,
    name               text,
    article_type       text,
    score              float
) as $$
begin
  return query
  select
    pm.internal_reference,
    pm.name,
    pm.article_type,
    round((
      extensions.similarity(norm(pm.name), norm(suchbegriff))       * 0.6 +
      extensions.word_similarity(norm(suchbegriff), norm(pm.name))  * 0.4
    )::numeric, 3)::float as score
  from product_master pm
  where
    (p_article_type is null or pm.article_type = p_article_type)
    and (
      extensions.similarity(norm(pm.name), norm(suchbegriff))         >= min_score
      or extensions.word_similarity(norm(suchbegriff), norm(pm.name)) >= min_score
    )
  order by score desc
  limit limit_n;
end;
$$ language plpgsql stable;
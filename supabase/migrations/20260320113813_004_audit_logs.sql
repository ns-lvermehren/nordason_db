-- Changelog für product_master
create table public.product_master_changelog (
    id            bigserial primary key,
    artikel_id    bigint      not null,
    internal_ref  text        not null,
    operation     text        not null check (operation in ('INSERT','UPDATE','DELETE')),
    geaendert_am  timestamptz not null default now(),
    geaendert_von text,
    felder        jsonb,
    alt           jsonb,
    neu           jsonb
);

create index idx_changelog_artikel
  on product_master_changelog(internal_ref, geaendert_am desc);

create index idx_changelog_user
  on product_master_changelog(geaendert_von, geaendert_am desc);

-- Changelog für bom
create table public.bom_changelog (
    id            bigserial primary key,
    bom_id        int         not null,
    operation     text        not null check (operation in ('INSERT','UPDATE','DELETE')),
    geaendert_am  timestamptz not null default now(),
    geaendert_von text,
    alt           jsonb,
    neu           jsonb
);

create index idx_bom_changelog_id
  on bom_changelog(bom_id, geaendert_am desc);

-- Trigger-Funktion product_master
create or replace function product_master_audit_trigger()
returns trigger as $$
declare
    v_felder  jsonb := '[]';
    v_alt     jsonb := '{}';
    v_neu     jsonb := '{}';
    v_user    text;
    key       text;
begin
    begin
        v_user := current_setting('app.current_user', true);
    exception when others then
        v_user := current_user;
    end;

    if tg_op = 'INSERT' then
        insert into product_master_changelog
            (artikel_id, internal_ref, operation, geaendert_von, neu)
        values (new.id, new.internal_reference, 'INSERT', v_user, to_jsonb(new));

    elsif tg_op = 'DELETE' then
        insert into product_master_changelog
            (artikel_id, internal_ref, operation, geaendert_von, alt)
        values (old.id, old.internal_reference, 'DELETE', v_user, to_jsonb(old));

    elsif tg_op = 'UPDATE' then
        for key in select jsonb_object_keys(to_jsonb(new)) loop
            if (to_jsonb(old) -> key) is distinct from (to_jsonb(new) -> key) then
                v_felder := v_felder || jsonb_build_array(key);
                v_alt    := v_alt    || jsonb_build_object(key, to_jsonb(old) -> key);
                v_neu    := v_neu    || jsonb_build_object(key, to_jsonb(new) -> key);
            end if;
        end loop;

        if jsonb_array_length(v_felder) > 0 then
            insert into product_master_changelog
                (artikel_id, internal_ref, operation, geaendert_von, felder, alt, neu)
            values
                (new.id, new.internal_reference, 'UPDATE',
                 v_user, v_felder, v_alt, v_neu);
        end if;
    end if;
    return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_product_master_audit on product_master;
create trigger trg_product_master_audit
    after insert or update or delete on product_master
    for each row execute function product_master_audit_trigger();

-- Trigger-Funktion bom
create or replace function bom_audit_trigger()
returns trigger as $$
declare v_user text;
begin
    begin
        v_user := current_setting('app.current_user', true);
    exception when others then
        v_user := current_user;
    end;

    if tg_op = 'INSERT' then
        insert into bom_changelog (bom_id, operation, geaendert_von, neu)
        values (new.id, 'INSERT', v_user, to_jsonb(new));
    elsif tg_op = 'DELETE' then
        insert into bom_changelog (bom_id, operation, geaendert_von, alt)
        values (old.id, 'DELETE', v_user, to_jsonb(old));
    elsif tg_op = 'UPDATE' then
        insert into bom_changelog (bom_id, operation, geaendert_von, alt, neu)
        values (new.id, 'UPDATE', v_user, to_jsonb(old), to_jsonb(new));
    end if;
    return new;
end;
$$ language plpgsql security definer;

drop trigger if exists trg_bom_audit on bom;
create trigger trg_bom_audit
    after insert or update or delete on bom
    for each row execute function bom_audit_trigger();
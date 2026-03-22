do $$
declare
    r            record;
    seq_name     text;
    current_max  bigint;
begin
    for r in select type, start_value from product_type loop
        seq_name := 'seq_artno_' || lower(replace(r.type, ' ', '_'));

        -- Höchste bereits vergebene Nummer für diesen Typ ermitteln
        execute format(
            'select coalesce(
                max(internal_reference::bigint),
                %s - 1
            )
            from product_master
            where article_type = %L
              and internal_reference ~ %L',
            r.start_value, r.type, '^[0-9]+$'
        ) into current_max;

        execute format(
            'create sequence if not exists %I
             start with %s
             increment by 1',
            seq_name,
            current_max + 1
        );

        raise notice 'Sequence % angelegt, startet bei %', seq_name, current_max + 1;
    end loop;
end;
$$;
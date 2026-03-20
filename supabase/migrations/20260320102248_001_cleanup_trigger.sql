create or replace function public.fn_manage_product_ids()
returns trigger language plpgsql as $$
begin
    new.updated_at := current_timestamp;
    return new;
end;
$$;

drop trigger if exists trg_manage_ids        on public.product_master;
drop trigger if exists trg_manage_ids_update on public.product_master;
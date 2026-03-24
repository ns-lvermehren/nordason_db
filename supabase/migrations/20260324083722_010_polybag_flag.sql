-- supabase/migrations/[ts]_010_polybag_flag.sql
ALTER TABLE public.product_master
  ADD COLUMN IF NOT EXISTS polybag BOOLEAN DEFAULT false;

ALTER TABLE public.staging_artikel
  ADD COLUMN IF NOT EXISTS polybag BOOLEAN DEFAULT false;
  
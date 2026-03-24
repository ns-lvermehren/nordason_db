-- supabase/migrations/[ts]_011_product_master_import_ref.sql
ALTER TABLE public.product_master
  ADD COLUMN IF NOT EXISTS import_version_id  INT REFERENCES bom_version(id),
  ADD COLUMN IF NOT EXISTS import_session_id  INT REFERENCES bom_session(id);

CREATE INDEX IF NOT EXISTS idx_pm_import_version ON public.product_master(import_version_id);
CREATE INDEX IF NOT EXISTS idx_pm_import_session ON public.product_master(import_session_id);
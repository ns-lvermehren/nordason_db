-- supabase/migrations/[ts]_007_bom_unique_parent_child.sql
CREATE UNIQUE INDEX IF NOT EXISTS bom_parent_child_unique
  ON public.bom (COALESCE(parent, ''), child);
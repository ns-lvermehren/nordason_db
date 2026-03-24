-- supabase/migrations/[ts]_009_bom_version_session.sql
ALTER TABLE public.bom
  ADD COLUMN IF NOT EXISTS version_id  INT REFERENCES bom_version(id),
  ADD COLUMN IF NOT EXISTS session_id  INT REFERENCES bom_session(id);

CREATE INDEX IF NOT EXISTS idx_bom_version  ON public.bom(version_id);
CREATE INDEX IF NOT EXISTS idx_bom_session  ON public.bom(session_id);
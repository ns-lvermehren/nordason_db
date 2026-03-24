-- supabase/migrations/[ts]_008_staging_artikel_status_freigegeben.sql
ALTER TABLE staging_artikel
DROP CONSTRAINT IF EXISTS staging_artikel_match_status_check;

ALTER TABLE staging_artikel
ADD CONSTRAINT staging_artikel_match_status_check
CHECK (match_status IN (
    'offen',
    'matched',       -- bereits in product_master vor dieser BOM
    'neu_anlegen',   -- wird bei Freigabe neu angelegt
    'freigegeben',   -- wurde durch Freigabe neu angelegt
    'ignorieren'
));
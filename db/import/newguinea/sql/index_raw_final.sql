-- Index on country
\set trf_country_idx :tbl_raw_final '_country_idx'
DROP INDEX IF EXISTS :trf_country_idx;
CREATE INDEX :trf_country_idx ON :tbl_raw_final (country);

-- Index on state_province
\set trf_state_province_idx :tbl_raw_final '_state_province_idx'
DROP INDEX IF EXISTS :trf_state_province_idx;
CREATE INDEX :trf_state_province_idx ON :tbl_raw_final (state_province);

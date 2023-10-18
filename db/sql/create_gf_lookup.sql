-- -----------------------------------------------------------------
-- Create temporary table in format of TNRS table gf_lookup
-- -----------------------------------------------------------------

DROP TABLE IF EXISTS gf_lookup;
CREATE TABLE gf_lookup (
gf_lookup_id serial not null,
genus text,
family text,
"source" text,
fams smallint
);

CREATE INDEX gf_lookup_temp_fams ON gf_lookup (fams);

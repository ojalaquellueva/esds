-- ------------------------------------------------------
-- Create generic staging table linking a checklist
-- source to a country, state or county. Enables separate
-- tracking of all political divisions covered by a single
-- source. Information needed for this table should be
-- provided in the params file for an individual source.
-- Note that only source_name is loaded initially; poldiv_id 
-- populated later when loading core database, therefore 
-- not set as PK in create table statement
-- ------------------------------------------------------


DROP TABLE IF EXISTS poldiv_source_staging;
CREATE TABLE poldiv_source_staging (
poldiv_id integer DEFAULT NULL, 
poldiv_type text NOT NULL, 
source_name text DEFAULT NULL, 
checklist_type text DEFAULT NULL,
checklist_details text DEFAULT NULL
);

CREATE INDEX poldiv_source_staging_checklist_type_idx
	ON poldiv_source_staging (checklist_type);
CREATE INDEX poldiv_source_staging_poldiv_id_idx
	ON poldiv_source_staging (poldiv_id);
CREATE INDEX poldiv_source_staging_poldiv_type_idx
	ON poldiv_source_staging (poldiv_type);
CREATE INDEX poldiv_source_staging_source_name_idx
	ON poldiv_source_staging (source_name);

-- -------------------------------------------------------------
-- Create & index generic staging table for loading data from 
-- single source
-- -------------------------------------------------------------

DROP TABLE IF EXISTS distribution_staging;
CREATE TABLE distribution_staging (
id SERIAL PRIMARY KEY,
source_name text NOT NULL,
country text NOT NULL,
state_province text DEFAULT NULL,
county_parish text DEFAULT NULL,
poldiv_full text DEFAULT NULL,
family text DEFAULT NULL,
genus text DEFAULT NULL,
species text DEFAULT NULL,
taxon text NOT NULL,
taxon_rank text DEFAULT NULL,
native_status text DEFAULT NULL,
native_status_details text DEFAULT NULL, 
cult_status text DEFAULT NULL
);

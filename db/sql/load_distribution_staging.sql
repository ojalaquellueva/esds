-- -------------------------------------------------------------
-- Load raw data to staging table 
-- Generic version for pre-standardized raw data
-- -------------------------------------------------------------

INSERT INTO distribution_staging (
source_name,
country,
state_province,
county_parish,
taxon,
taxon_rank,
native_status,
cult_status
)
SELECT
:'src',
country,
state_province,
county_parish,
taxon,
taxon_rank,
native_status,
cult_status
FROM :tbl_raw_generic
;

-- -----------------------------------------------------------------------
-- Add missing families for genera
-- -----------------------------------------------------------------------

-- Look up missing families
UPDATE distribution_staging a 
SET family=b.family
FROM gf_lookup b
WHERE a.genus=b.genus

;

-- Create temporary table of missing poldiv+family combinations
DROP TABLE IF EXISTS temp_missing_family
;
CREATE TABLE temp_missing_family AS
SELECT DISTINCT country, state_province, county_parish, family
FROM distribution_staging
WHERE native_status<>'introduced' AND taxon_rank<>'hybrid'
AND family IS NOT NULL AND TRIM(family)<>''
;
ALTER TABLE temp_missing_family
ADD COLUMN del text DEFAULT NULL
;

CREATE INDEX temp_missing_family_country_idx ON temp_missing_family (country);
CREATE INDEX temp_missing_family_state_province_idx ON temp_missing_family (state_province);
CREATE INDEX temp_missing_family_county_parish_idx ON temp_missing_family (county_parish);
CREATE INDEX temp_missing_family_family_idx ON temp_missing_family (family);

-- Mark family+poldiv combinations already present
UPDATE temp_missing_family f 
SET del='DELETE'
FROM distribution_staging d
WHERE f.family=d.taxon 
AND f.country=d.country 
AND f.state_province=d.state_province
AND f.county_parish=d.county_parish
;

CREATE INDEX temp_missing_family_del_idx ON temp_missing_family (del);

-- Delete marked records
DELETE FROM temp_missing_family
WHERE del='DELETE' OR family IS NULL OR TRIM(family)=''
;

-- Insert missing families
INSERT INTO distribution_staging (
source_name,
country,
state_province,
county_parish,
taxon,
taxon_rank,
native_status,
cult_status,
family
)
SELECT
:'src',
country,
state_province,
county_parish,
family,
'family',
'native',
'unknown',
family
FROM temp_missing_family
;

-- Drop temporary table
DROP TABLE temp_missing_family;

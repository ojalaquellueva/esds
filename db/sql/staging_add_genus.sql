-- -----------------------------------------------------------------------
-- Add missing genera for species
-- -----------------------------------------------------------------------

-- Populate genus column...";
UPDATE distribution_staging
SET genus=TRIM(split_part(taxon,' ',1))
;

-- Create temporary table of missing country+genus combinations
DROP TABLE IF EXISTS temp_missing_genus
;
CREATE TABLE temp_missing_genus AS
SELECT DISTINCT country, state_province, county_parish, genus
FROM distribution_staging
WHERE native_status IN ('native','endemic') AND taxon_rank<>'hybrid'
;

ALTER TABLE temp_missing_genus
ADD COLUMN del text default null
;

CREATE INDEX temp_missing_genus_country_idx ON temp_missing_genus (country);
CREATE INDEX temp_missing_genus_state_province_idx ON temp_missing_genus (state_province);
CREATE INDEX temp_missing_genus_county_parish_idx ON temp_missing_genus (county_parish);
CREATE INDEX temp_missing_genus_genus_idx ON temp_missing_genus (genus);

-- Mark genus+poldiv combinations already present
UPDATE temp_missing_genus g 
SET del='DELETE'
FROM distribution_staging d
WHERE g.genus=d.taxon 
AND g.country=d.country 
AND g.state_province=d.state_province
AND g.county_parish=d.county_parish
;

CREATE INDEX temp_missing_genus_del_idx ON temp_missing_genus (del);

-- Delete marked records
DELETE FROM temp_missing_genus
WHERE del='DELETE' OR genus IS NULL OR TRIM(genus)=''
;

-- Insert missing genera...";
INSERT INTO distribution_staging (
source_name,
country,
state_province,
county_parish,
taxon,
taxon_rank,
native_status,
cult_status,
genus
)
SELECT
:'src',
country,
state_province,
county_parish,
genus,
'genus',
'native',
'unknown',
genus
FROM temp_missing_genus
;

-- Drop temporary table
DROP TABLE temp_missing_genus
;

-- -----------------------------------------------------------------------
-- Add missing species for subspecific taxa
-- -----------------------------------------------------------------------

-- Populate species column
UPDATE distribution_staging
SET species=trim(split_part(taxon,' ',1) || ' ' || split_part(taxon,' ',2))
;

-- Create temporary table of missing country+species combinations
DROP TABLE IF EXISTS temp_missing_species
;
-- Only need to extract species if taxon is infraspecific
CREATE TABLE temp_missing_species AS
SELECT DISTINCT country, state_province, county_parish, species
FROM distribution_staging
WHERE native_status IN ('native','endemic') AND taxon_rank<>'hybrid'
AND taxon LIKE '% % %';
;

ALTER TABLE temp_missing_species
ADD COLUMN del text DEFAULT NULL
;

CREATE INDEX temp_missing_species_country_idx ON temp_missing_species (country);
CREATE INDEX temp_missing_species_state_province_idx ON temp_missing_species (state_province);
CREATE INDEX temp_missing_species_county_parish_idx ON temp_missing_species (county_parish);
CREATE INDEX temp_missing_species_species_idx ON temp_missing_species (species);

-- Mark species+poldiv combinations already present
UPDATE temp_missing_species s 
SET del='DELETE'
FROM distribution_staging d
WHERE d.taxon LIKE '% % %'
AND s.species=d.taxon 
AND s.country=d.country 
AND s.state_province=d.state_province
AND s.county_parish=d.county_parish
;

CREATE INDEX temp_missing_species_del_idx ON temp_missing_species (del);

-- Delete marked records
DELETE FROM temp_missing_species
WHERE del='DELETE'
;

-- Insert missing species
INSERT INTO distribution_staging (
source_name,
country,
state_province,
county_parish,
taxon,
taxon_rank,
native_status,
cult_status,
species
)
SELECT
:'src',
country,
state_province,
county_parish,
species,
'species',
'native',
'unknown',
species
FROM temp_missing_species
;

-- Drop temporary table
DROP TABLE temp_missing_species;

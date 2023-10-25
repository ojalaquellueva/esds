------------------------------------------------------
-- Load country checklists metadata to staging table
------------------------------------------------------

INSERT INTO poldiv_source_staging (
poldiv_id, 
poldiv_type, 
source_name, 
checklist_type,
checklist_details
)
SELECT DISTINCT
country_id, 
'country', 
:'src', 
'comprehensive',
:'source_name_full'
FROM country
WHERE country IN (:'cclist_countries_inlist')
;

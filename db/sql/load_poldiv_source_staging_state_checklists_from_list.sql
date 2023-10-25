INSERT INTO poldiv_source_staging (
poldiv_id, 
poldiv_type, 
source_name, 
checklist_type,
checklist_details
)
SELECT DISTINCT
state_province_id, 
'state_province', 
:'src', 
'comprehensive',
:'source_name_full'
FROM state_province
WHERE country IN (:'cclist_countries_inlist')
;

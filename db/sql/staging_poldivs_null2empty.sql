UPDATE distribution_staging
SET 
country=COALESCE(country,''),
state_province=COALESCE(state_province,''),
county_parish=COALESCE(county_parish,'')
;

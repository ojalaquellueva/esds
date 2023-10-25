UPDATE distribution_staging
SET 
country=
	CASE
	WHEN TRIM(country)='' THEN NULL
	ELSE country
	END,
state_province=
	CASE
	WHEN TRIM(state_province)='' THEN NULL
	ELSE state_province
	END,
county_parish=
	CASE
	WHEN TRIM(county_parish)='' THEN NULL
	ELSE county_parish
	END	
;
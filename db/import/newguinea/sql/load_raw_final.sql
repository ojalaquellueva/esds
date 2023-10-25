-- ----------------------------------------------------
-- Load country- and state-level observations
-- ----------------------------------------------------

-- Papua New Guinea
INSERT INTO :tbl_raw_final (
taxon,
country,
state_province,
county_parish,
native_status
) 
SELECT
"fullname_expert_verified",
'Papua New Guinea',
NULL,
NULL,
CASE
WHEN endemic='y' THEN 'endemic'
WHEN endemic='n' AND native='y' THEN 'native'
WHEN native<>'y' THEN 'introduced'
ELSE 'unknown'
END
FROM :tbl_raw
WHERE "png"='y'
;

-- Indonesia: Papua (gadm name_1='Papua')
INSERT INTO :tbl_raw_final (
taxon,
country,
state_province,
county_parish,
native_status
) 
SELECT
"fullname_expert_verified",
'Indonesia',
'Papua',
NULL,
CASE
WHEN endemic='y' THEN 'endemic'
WHEN endemic='n' AND native='y' THEN 'native'
WHEN native<>'y' THEN 'introduced'
ELSE 'unknown'
END
FROM :tbl_raw
WHERE "idn"='y'
;

-- Indonesia: West Papua (gadm name_1='Papua Barat')
INSERT INTO :tbl_raw_final (
taxon,
country,
state_province,
county_parish,
native_status
) 
SELECT
"fullname_expert_verified",
'Indonesia',
'Papua Barat',
NULL,
CASE
WHEN endemic='y' THEN 'endemic'
WHEN endemic='n' AND native='y' THEN 'native'
WHEN native<>'y' THEN 'introduced'
ELSE 'unknown'
END
FROM :tbl_raw
WHERE "idn"='y'
;

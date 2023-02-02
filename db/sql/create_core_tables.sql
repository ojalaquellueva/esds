--
-- Metadata tables
--

DROP TABLE IF EXISTS meta;
CREATE TABLE meta (
id SERIAL NOT NULL PRIMARY KEY,
db_version TEXT DEFAULT NULL,
db_version_comments TEXT DEFAULT NULL,
db_version_build_date date,
code_version TEXT DEFAULT NULL,
code_version_comments TEXT DEFAULT NULL,
code_version_release_date date,
citation TEXT DEFAULT NULL,
publication TEXT DEFAULT NULL,
logo_path TEXT DEFAULT NULL 
);

DROP TABLE IF EXISTS source;
CREATE TABLE source (
source_id SERIAL NOT NULL PRIMARY KEY,
source_name TEXT NOT NULL,
source_name_full TEXT DEFAULT NULL,
source_url TEXT DEFAULT NULL,
description TEXT DEFAULT NULL,
data_url TEXT DEFAULT NULL,
source_version TEXT DEFAULT NULL,
source_release_date DATE DEFAULT NULL,
date_accessed DATE DEFAULT NULL,
citation TEXT DEFAULT NULL,
logo_path TEXT DEFAULT NULL
);

DROP TABLE IF EXISTS collaborator;
CREATE TABLE collaborator (
collaborator_id SERIAL NOT NULL PRIMARY KEY,
collaborator_name TEXT DEFAULT NULL,
collaborator_name_full TEXT DEFAULT NULL,
collaborator_url TEXT DEFAULT NULL,
description TEXT DEFAULT NULL,
logo_path TEXT DEFAULT NULL
);

--
-- Data tables
--

DROP TABLE IF EXISTS distribution;
CREATE TABLE distribution (
distribution_id SERIAL NOT NULL PRIMARY KEY, 
source_id INTEGER NOT NULL,
taxon_rank TEXT NOT NULL,
taxon TEXT NOT NULL,
country TEXT NOT NULL,
state_province TEXT DEFAULT NULL,
state_province_full TEXT DEFAULT NULL,
county_parish TEXT DEFAULT NULL,
county_parish_full TEXT DEFAULT NULL,
poldiv_full TEXT DEFAULT NULL,
poldiv_type TEXT DEFAULT NULL,
native_status TEXT DEFAULT NULL,
native_status_details TEXT DEFAULT NULL, 
cult_status TEXT DEFAULT NULL,
is_cultivated_taxon SMALLINT DEFAULT 0, 
FOREIGN KEY (source_id) REFERENCES source(source_id)
);

DROP TABLE IF EXISTS cclist;
CREATE TABLE cclist (
country TEXT NOT NULL,
state_province TEXT DEFAULT '',
county_parish TEXT DEFAULT ''
);

DROP TABLE IF EXISTS country;
CREATE TABLE country (
country_id INTEGER NOT NULL PRIMARY KEY, 
country TEXT NOT NULL,
country_iso TEXT NOT NULL,
country_iso_alpha3 TEXT DEFAULT NULL,
country_fips TEXT DEFAULT NULL
);

-- poldiv type is also the name of the table
-- to which FK poldiv_id points
DROP TABLE IF EXISTS poldiv_source;
CREATE TABLE poldiv_source (
poldiv_source_id SERIAL NOT NULL PRIMARY KEY,  
poldiv_id INTEGER NOT NULL, 
poldiv_name TEXT DEFAULT NULL,
poldiv_type TEXT NOT NULL,
source_id INTEGER NOT NULL, 
checklist_type TEXT DEFAULT NULL,
checklist_details TEXT DEFAULT NULL
);

DROP TABLE IF EXISTS state_province;
CREATE TABLE state_province (
state_province_id INTEGER NOT NULL PRIMARY KEY, 
country TEXT DEFAULT NULL, 
country_iso TEXT DEFAULT NULL, 
state_province TEXT DEFAULT NULL, 
state_province_ascii TEXT DEFAULT NULL, 
state_province_code TEXT DEFAULT NULL, 
state_province_code_unique TEXT DEFAULT NULL
);

DROP TABLE IF EXISTS cultspp;
CREATE TABLE cultspp (
cultspp_id SERIAL NOT NULL PRIMARY KEY, 
source_id INTEGER NOT NULL,
taxon TEXT NOT NULL,
FOREIGN KEY (source_id) REFERENCES source(source_id)
);

DROP TABLE IF EXISTS cache;
CREATE TABLE cache (
id SERIAL NOT NULL PRIMARY KEY, 
family TEXT DEFAULT NULL,
genus TEXT DEFAULT NULL,
species TEXT DEFAULT NULL,
country TEXT DEFAULT NULL,
state_province TEXT DEFAULT NULL,
state_province_full TEXT DEFAULT NULL,
county_parish TEXT DEFAULT NULL,
county_parish_full TEXT DEFAULT NULL,
poldiv_full TEXT DEFAULT NULL,
poldiv_type TEXT DEFAULT NULL,
native_status_country TEXT DEFAULT NULL,
native_status_state_province TEXT DEFAULT NULL,
native_status_county_parish TEXT DEFAULT NULL,
native_status TEXT DEFAULT NULL,
native_status_reason TEXT DEFAULT NULL,
native_status_sources TEXT DEFAULT NULL,
isIntroduced SMALLINT DEFAULT NULL,
isCultivatedNSR SMALLINT DEFAULT 0,
is_cultivated_taxon SMALLINT DEFAULT 0
)
;

-- User-submitted observations plus NSR resolution results
DROP TABLE IF EXISTS observation;
CREATE TABLE observation (
id SERIAL NOT NULL PRIMARY KEY, 
job TEXT NOT NULL, 
batch INTEGER DEFAULT NULL,
family TEXT DEFAULT NULL,
genus TEXT DEFAULT NULL,
species TEXT DEFAULT NULL,
country TEXT NOT NULL,
state_province TEXT DEFAULT NULL,
state_province_full TEXT DEFAULT NULL,
county_parish TEXT DEFAULT NULL,
county_parish_full TEXT DEFAULT NULL,
poldiv_full TEXT DEFAULT NULL,
poldiv_type TEXT DEFAULT NULL,
native_status_country TEXT DEFAULT NULL,
native_status_state_province TEXT DEFAULT NULL,
native_status_county_parish TEXT DEFAULT NULL,
native_status TEXT DEFAULT NULL,
native_status_reason TEXT DEFAULT NULL,
native_status_sources TEXT DEFAULT NULL,
isIntroduced SMALLINT DEFAULT NULL,
isCultivatedNSR SMALLINT DEFAULT 0,
is_cultivated_taxon SMALLINT DEFAULT 0,
is_in_cache INTEGER DEFAULT 0,
user_id INTEGER DEFAULT NULL
);

-- Lookup of family for a genus
-- Indexes added after loading
DROP TABLE IF EXISTS gf_lookup;
CREATE TABLE gf_lookup (
gf_lookup_id SERIAL NOT NULL PRIMARY KEY, 
genus TEXT NOT NULL,
family TEXT NOT NULL,
source TEXT NOT NULL
)
;


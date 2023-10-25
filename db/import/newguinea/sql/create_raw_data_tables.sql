DROP TABLE IF EXISTS :tbl_raw ;
CREATE TABLE :tbl_raw (
higher_taxon text DEFAULT NULL,
family_original text DEFAULT NULL,
fullname_original text DEFAULT NULL,
taxonomic_status_tnrs text DEFAULT NULL,
family_tnrs text DEFAULT NULL,
acceptedname_tnrs text DEFAULT NULL,
authorname_tnrs text DEFAULT NULL,
family_expert_verified text DEFAULT NULL,
fullname_expert_verified text DEFAULT NULL,
authorname_expert_verified text DEFAULT NULL,
native text DEFAULT NULL,
endemic text DEFAULT NULL,
idn text DEFAULT NULL,
png text DEFAULT NULL,
life_form text DEFAULT NULL,
checked_by text DEFAULT NULL,
reference_consulted text DEFAULT NULL,
notes text DEFAULT NULL,
notes2 text DEFAULT NULL,
woody text DEFAULT NULL,
basionym_year text DEFAULT NULL
);


DROP TABLE IF EXISTS :tbl_raw_final ;
CREATE TABLE :tbl_raw_final (
taxon text DEFAULT NULL,
taxon_rank text DEFAULT NULL,
country text DEFAULT NULL,
state_province text DEFAULT NULL,
county_parish text DEFAULT NULL,
native_status text DEFAULT NULL,
cult_status text DEFAULT NULL
);

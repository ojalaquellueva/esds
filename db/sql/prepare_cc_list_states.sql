-- -------------------------------------------------------------
-- Load IDs, country and names of states/provinces represented
-- by comprehensive checklists for this source
-- -------------------------------------------------------------

DROP TABLE IF EXISTS :tbl_cclist_states;
CREATE TABLE :tbl_cclist_states AS
SELECT DISTINCT
b.state_province_id,
b.country,
b.state_province_std
FROM :tbl_raw_generic a JOIN state_province b
ON a.country=b.country AND a.state_province=b.state_province_std
;

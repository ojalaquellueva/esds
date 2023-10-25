-- ---------------------------------------------------------------
-- Drop all raw data tables from main schema
-- ---------------------------------------------------------------

\set tbl_raw :src '_raw'
\set tbl_raw_final :src '_raw_final'
\set tbl_cclist_states :src '_cclist_states'

DROP TABLE IF EXISTS 
:"tbl_raw",
:"tbl_raw_final",
:"tbl_cclist_states"
;	

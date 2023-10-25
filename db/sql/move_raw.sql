-- ---------------------------------------------------------------
-- Move raw data tables to staging schema
-- ---------------------------------------------------------------

\set tbl_raw :src '_raw'
\set tbl_raw_final :src '_raw_final'
\set tbl_cclist_states :src '_cclist_states'

ALTER TABLE IF EXISTS :"tbl_raw" SET SCHEMA staging;
ALTER TABLE IF EXISTS :"tbl_raw_final" SET SCHEMA staging;
ALTER TABLE IF EXISTS :"tbl_cclist_states" SET SCHEMA staging;

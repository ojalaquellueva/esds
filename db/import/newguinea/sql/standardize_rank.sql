------------------------------------------------------------------
-- Expand standard rank indicators to unabbreviated form
-- Needed for parsing name from authors
------------------------------------------------------------------

UPDATE :tbl_raw_final
SET taxon_rank=
CASE
WHEN taxon_rank='cv.' THEN 'cultivar'
WHEN taxon_rank='fo.' THEN 'forma'
WHEN taxon_rank='subsp.' THEN 'subspecies'
WHEN taxon_rank='var.' THEN 'variety'
ELSE taxon_rank
END
;

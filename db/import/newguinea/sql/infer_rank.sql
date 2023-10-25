-- ----------------------------------------------------------------
-- Extract taxonomic rank from taxon name
-- ----------------------------------------------------------------

-- Remove cf. and aff.
UPDATE :tbl_raw_final
SET taxon=REPLACE(taxon, ' aff.', '')
WHERE taxon like '% aff.%'
;
UPDATE :tbl_raw_final
SET taxon=REPLACE(taxon, ' cf.', '')
WHERE taxon like '% cf.%'
;


-- Create temporary taxon_rank column (rank_temp)
ALTER TABLE :tbl_raw_final
DROP COLUMN IF EXISTS rank_temp
;
ALTER TABLE :tbl_raw_final
ADD COLUMN rank_temp text DEFAULT NULL
;

-- Dump third token of name to temp taxon_rank column,
-- setting empty strings to NULL
UPDATE :tbl_raw_final
SET rank_temp=trim(split_part(taxon,' ',3))
;
UPDATE :tbl_raw_final
SET rank_temp=NULL
WHERE rank_temp=''
;

-- Index temp and final rank columns
\set trf_rank_temp_idx :tbl_raw_final '_rank_temp_idx'
DROP INDEX IF EXISTS :trf_rank_temp_idx;
CREATE INDEX :trf_rank_temp_idx ON :tbl_raw_final (rank_temp);
-- Just index NULLs
\set trf_taxon_rank_isnull_idx :tbl_raw_final '_taxon_rank_idx'
DROP INDEX IF EXISTS :trf_taxon_rank_isnull_idx;
CREATE INDEX :trf_taxon_rank_isnull_idx ON :tbl_raw_final (taxon_rank) 
	WHERE taxon_rank IS NULL;

-- Set temp rank values to all lower case
UPDATE :tbl_raw_final
SET rank_temp=LOWER(rank_temp)
WHERE rank_temp IS NOT NULL
;

-- Detect and flag hybrids
UPDATE :tbl_raw_final
SET rank_temp='hybrid'
WHERE taxon like '% x %' OR taxon like 'x %' OR taxon like '% × %' OR taxon like '× %'
;

-- Update standard rank indicators of infraspecific taxa
-- based on verbatim values in rank_temp
UPDATE :tbl_raw_final
SET taxon_rank=
	CASE
	WHEN rank_temp='agsp' THEN 'agsp.'
	WHEN rank_temp='agsp.' THEN 'agsp.'
	WHEN rank_temp='convar.' THEN 'convar.'
	WHEN rank_temp='convar' THEN 'convar.'
	WHEN rank_temp='cult.' THEN 'cv.'
	WHEN rank_temp='cult' THEN 'cv.'
	WHEN rank_temp='cultivar' THEN 'cv.'
	WHEN rank_temp='cv' THEN 'cv.'
	WHEN rank_temp='cv..' THEN 'cv.'
	WHEN rank_temp='cv' THEN 'cv.'
	WHEN rank_temp='fo.' THEN 'fo.'
	WHEN rank_temp='fo' THEN 'fo.'
	WHEN rank_temp='f.' THEN 'fo.'
	WHEN rank_temp='forma' THEN 'fo.'
	WHEN rank_temp='grex' THEN 'grex'
	WHEN rank_temp='lusus' THEN 'lusus'
	WHEN rank_temp='monstr' THEN 'monstr.'
	WHEN rank_temp='nohtosubsp' THEN 'nothosubsp.'
	WHEN rank_temp='nothogen' THEN 'nothogen.'
	WHEN rank_temp='nothomorph' THEN 'nothomorph'
	WHEN rank_temp='nothosect.' THEN 'nothosect.'
	WHEN rank_temp='nothosect' THEN 'nothosect.'
	WHEN rank_temp='nothoser.' THEN 'nothoser.'
	WHEN rank_temp='nothoser' THEN 'nothoser.'
	WHEN rank_temp='nothosubgen.' THEN 'nothosubgen.'
	WHEN rank_temp='nothosubgen' THEN 'nothosubgen.'
	WHEN rank_temp='nothosbgen' THEN 'nothosubgen.'
	WHEN rank_temp='nothosbgen' THEN 'nothosubgen.'
	WHEN rank_temp='nothosubsp.' THEN 'nothosubsp.'
	WHEN rank_temp='nothosubsp.' THEN 'nothosubsp.'
	WHEN rank_temp='nothosbsp.' THEN 'nothosubsp.'
	WHEN rank_temp='nothosbsp.' THEN 'nothosubsp.'
	WHEN rank_temp='nothossp.' THEN 'nothosubsp.'
	WHEN rank_temp='nothossp' THEN 'nothosubsp.'
	WHEN rank_temp='nothovar.' THEN 'nothovar.'
	WHEN rank_temp='nothovar' THEN 'nothovar.'
	WHEN rank_temp='proles' THEN 'proles'
	WHEN rank_temp='race' THEN 'race'
	WHEN rank_temp='rasse' THEN 'race'
	WHEN rank_temp='sect.' THEN 'sect.'
	WHEN rank_temp='sect' THEN 'sect.'
	WHEN rank_temp='ser' THEN 'ser.'
	WHEN rank_temp='ser.' THEN 'ser.'
	WHEN rank_temp='sport' THEN 'sport'
	WHEN rank_temp='stirps' THEN 'stirps'
	WHEN rank_temp='subfo.' THEN 'subfo.'
	WHEN rank_temp='subfo' THEN 'subfo.'
	WHEN rank_temp='subf.' THEN 'subfo.'
	WHEN rank_temp='subf' THEN 'subfo.'
	WHEN rank_temp='subforma.' THEN 'subfo.'
	WHEN rank_temp='sbfo.' THEN 'subfo.'
	WHEN rank_temp='sbforma' THEN 'subfo.'
	WHEN rank_temp='subgen.' THEN 'subgen.'
	WHEN rank_temp='subgen' THEN 'subgen.'
	WHEN rank_temp='subsect' THEN 'subsect.'
	WHEN rank_temp='subsect.' THEN 'subsect.'
	WHEN rank_temp='subser.' THEN 'subser.'
	WHEN rank_temp='subser' THEN 'subser.'
	WHEN rank_temp='subsp' THEN 'subsp.'
	WHEN rank_temp='subsp.' THEN 'subsp.'
	WHEN rank_temp='sbsp.' THEN 'subsp.'
	WHEN rank_temp='sbsp' THEN 'subsp.'
	WHEN rank_temp='ssp.' THEN 'subsp.'
	WHEN rank_temp='ssp' THEN 'subsp.'
	WHEN rank_temp='subspecies' THEN 'subsp.'
	WHEN rank_temp='substirps' THEN 'substirps'
	WHEN rank_temp='subvar.' THEN 'subvar.'
	WHEN rank_temp='subvar' THEN 'subvar.'
	WHEN rank_temp='supersect.' THEN 'supersect.'
	WHEN rank_temp='var' THEN 'var.'
	WHEN rank_temp='var.' THEN 'var.'
	WHEN rank_temp='variety' THEN 'var.'
	ELSE 'UNKNOWN_RANK'
	END
WHERE rank_temp IS NOT NULL AND taxon_rank IS NULL
;

-- Mop up edge cases. Mostly, where rank indicator is not third token
UPDATE :tbl_raw_final
SET taxon_rank=
	CASE
	WHEN taxon LIKE '% agsp %' THEN 'agsp.'
	WHEN taxon LIKE '% agsp. %' THEN 'agsp.'
	WHEN taxon LIKE '% convar. %' THEN 'convar.'
	WHEN taxon LIKE '% convar %' THEN 'convar.'
	WHEN taxon LIKE '% cult. %' THEN 'cv.'
	WHEN taxon LIKE '% cult %' THEN 'cv.'
	WHEN taxon LIKE '% cultivar %' THEN 'cv.'
	WHEN taxon LIKE '% cv %' THEN 'cv.'
	WHEN taxon LIKE '% cv.. %' THEN 'cv.'
	WHEN taxon LIKE '% cv %' THEN 'cv.'
	WHEN taxon LIKE '% fo. %' THEN 'fo.'
	WHEN taxon LIKE '% fo %' THEN 'fo.'
	WHEN taxon LIKE '% f. %' THEN 'fo.'
	WHEN taxon LIKE '% forma %' THEN 'fo.'
	WHEN taxon LIKE '% grex %' THEN 'grex'
	WHEN taxon LIKE '% lusus %' THEN 'lusus'
	WHEN taxon LIKE '% monstr %' THEN 'monstr.'
	WHEN taxon LIKE '% nohtosubsp %' THEN 'nothosubsp.'
	WHEN taxon LIKE '% nothogen %' THEN 'nothogen.'
	WHEN taxon LIKE '% nothomorph %' THEN 'nothomorph'
	WHEN taxon LIKE '% nothosect. %' THEN 'nothosect.'
	WHEN taxon LIKE '% nothosect %' THEN 'nothosect.'
	WHEN taxon LIKE '% nothoser. %' THEN 'nothoser.'
	WHEN taxon LIKE '% nothoser %' THEN 'nothoser.'
	WHEN taxon LIKE '% nothosubgen. %' THEN 'nothosubgen.'
	WHEN taxon LIKE '% nothosubgen %' THEN 'nothosubgen.'
	WHEN taxon LIKE '% nothosbgen %' THEN 'nothosubgen.'
	WHEN taxon LIKE '% nothosbgen %' THEN 'nothosubgen.'
	WHEN taxon LIKE '% nothosubsp. %' THEN 'nothosubsp.'
	WHEN taxon LIKE '% nothosubsp. %' THEN 'nothosubsp.'
	WHEN taxon LIKE '% nothosbsp. %' THEN 'nothosubsp.'
	WHEN taxon LIKE '% nothosbsp. %' THEN 'nothosubsp.'
	WHEN taxon LIKE '% nothossp. %' THEN 'nothosubsp.'
	WHEN taxon LIKE '% nothossp %' THEN 'nothosubsp.'
	WHEN taxon LIKE '% nothovar. %' THEN 'nothovar.'
	WHEN taxon LIKE '% nothovar %' THEN 'nothovar.'
	WHEN taxon LIKE '% proles %' THEN 'proles'
	WHEN taxon LIKE '% race %' THEN 'race'
	WHEN taxon LIKE '% rasse %' THEN 'race'
	WHEN taxon LIKE '% sect. %' THEN 'sect.'
	WHEN taxon LIKE '% sect %' THEN 'sect.'
	WHEN taxon LIKE '% ser %' THEN 'ser.'
	WHEN taxon LIKE '% ser. %' THEN 'ser.'
	WHEN taxon LIKE '% sport %' THEN 'sport'
	WHEN taxon LIKE '% stirps %' THEN 'stirps'
	WHEN taxon LIKE '% subfo. %' THEN 'subfo.'
	WHEN taxon LIKE '% subfo %' THEN 'subfo.'
	WHEN taxon LIKE '% subf. %' THEN 'subfo.'
	WHEN taxon LIKE '% subf %' THEN 'subfo.'
	WHEN taxon LIKE '% subforma. %' THEN 'subfo.'
	WHEN taxon LIKE '% sbfo. %' THEN 'subfo.'
	WHEN taxon LIKE '% sbforma %' THEN 'subfo.'
	WHEN taxon LIKE '% subgen. %' THEN 'subgen.'
	WHEN taxon LIKE '% subgen %' THEN 'subgen.'
	WHEN taxon LIKE '% subsect %' THEN 'subsect.'
	WHEN taxon LIKE '% subsect. %' THEN 'subsect.'
	WHEN taxon LIKE '% subser. %' THEN 'subser.'
	WHEN taxon LIKE '% subser %' THEN 'subser.'
	WHEN taxon LIKE '% subsp %' THEN 'subsp.'
	WHEN taxon LIKE '% subsp. %' THEN 'subsp.'
	WHEN taxon LIKE '% sbsp. %' THEN 'subsp.'
	WHEN taxon LIKE '% sbsp %' THEN 'subsp.'
	WHEN taxon LIKE '% ssp. %' THEN 'subsp.'
	WHEN taxon LIKE '% ssp %' THEN 'subsp.'
	WHEN taxon LIKE '% subspecies %' THEN 'subsp.'
	WHEN taxon LIKE '% substirps %' THEN 'substirps'
	WHEN taxon LIKE '% subvar. %' THEN 'subvar.'
	WHEN taxon LIKE '% subvar %' THEN 'subvar.'
	WHEN taxon LIKE '% supersect. %' THEN 'supersect.'
	WHEN taxon LIKE '% var %' THEN 'var.'
	WHEN taxon LIKE '% var. %' THEN 'var.'
	WHEN taxon LIKE '% variety %' THEN 'var.'
	ELSE NULL
	END
WHERE taxon_rank='UNKNOWN_RANK' OR taxon_rank IS NULL
;

-- Mark remaining rows as species or hybrids
UPDATE :tbl_raw_final
SET taxon_rank=
	CASE
	WHEN rank_temp='hybrid' THEN 'hybrid'
	ELSE 'species'
	END
WHERE taxon_rank IS NULL
;		

-- Remove temporary rank column
ALTER TABLE :tbl_raw_final
DROP COLUMN rank_temp
;

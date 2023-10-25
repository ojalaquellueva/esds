-- -------------------------------------------------------------
-- Standardize native status codes in staging table
-- -------------------------------------------------------------

UPDATE distribution_staging
SET native_status='introduced'
WHERE native_status='not native' OR native_status='non-native' OR native_status='Introduced' OR native_status='absent'
;

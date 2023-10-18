
DROP INDEX IF EXISTS source_source_name_idx;
DROP INDEX IF EXISTS source_is_comprehensive_idx;
DROP INDEX IF EXISTS source_regional_scope_idx;
DROP INDEX IF EXISTS source_taxonomic_scope_idx;

DROP INDEX IF EXISTS distribution_taxon_rank_idx;
DROP INDEX IF EXISTS distribution_taxon_idx;
DROP INDEX IF EXISTS distribution_country_idx;
DROP INDEX IF EXISTS distribution_state_province_idx;
DROP INDEX IF EXISTS distribution_county_parish_idx;
DROP INDEX IF EXISTS distribution_native_status_idx;
DROP INDEX IF EXISTS distribution_cult_status_idx;
DROP INDEX IF EXISTS distribution_is_cultivated_taxon_idx;

DROP INDEX IF EXISTS cache_family_idx;
DROP INDEX IF EXISTS cache_genus_idx;
DROP INDEX IF EXISTS cache_species_idx;
DROP INDEX IF EXISTS cache_country_idx;
DROP INDEX IF EXISTS cache_state_province_idx;
DROP INDEX IF EXISTS cache_county_parish_idx;
DROP INDEX IF EXISTS cache_state_province_full_idx;
DROP INDEX IF EXISTS cache_county_parish_full_idx;
DROP INDEX IF EXISTS cache_poldiv_full_idx;
DROP INDEX IF EXISTS cache_poldiv_type_idx;

DROP INDEX IF EXISTS observation_job_idx;
DROP INDEX IF EXISTS observation_batch_idx;
DROP INDEX IF EXISTS observation_family_idx;
DROP INDEX IF EXISTS observation_genus_idx;
DROP INDEX IF EXISTS observation_species_idx;
DROP INDEX IF EXISTS observation_country_idx;
DROP INDEX IF EXISTS observation_state_province_idx;
DROP INDEX IF EXISTS observation_county_parish_idx;
DROP INDEX IF EXISTS observation_state_province_full_idx;
DROP INDEX IF EXISTS observation_county_parish_full_idx;
DROP INDEX IF EXISTS observation_poldiv_full_idx;
DROP INDEX IF EXISTS observation_poldiv_type_idx;
DROP INDEX IF EXISTS observation_native_status_country_idx;
DROP INDEX IF EXISTS observation_native_status_state_province_idx;
DROP INDEX IF EXISTS observation_native_status_county_parish_idx;
DROP INDEX IF EXISTS observation_native_status_idx;
DROP INDEX IF EXISTS observation_native_status_reason_idx;
DROP INDEX IF EXISTS observation_native_status_sources_idx;
DROP INDEX IF EXISTS observation_isIntroduced_idx;
DROP INDEX IF EXISTS observation_isCultivatedNSR_idx;
DROP INDEX IF EXISTS observation_is_cultivated_taxon_idx;
DROP INDEX IF EXISTS observation_is_in_cache_idx;

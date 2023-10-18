
CREATE INDEX source_source_name_idx ON "source" (source_name);
CREATE INDEX source_is_comprehensive_idx ON "source" (is_comprehensive);
CREATE INDEX source_regional_scope_idx ON "source" (regional_scope);
CREATE INDEX source_taxonomic_scope_idx ON "source" (taxonomic_scope);

CREATE INDEX distribution_taxon_rank_idx ON distribution (taxon_rank);
CREATE INDEX distribution_taxon_idx ON distribution (taxon);
CREATE INDEX distribution_country_idx ON distribution (country);
CREATE INDEX distribution_state_province_idx ON distribution (state_province);
CREATE INDEX distribution_county_parish_idx ON distribution (county_parish);
CREATE INDEX distribution_native_status_idx ON distribution (native_status);
CREATE INDEX distribution_cult_status_idx ON distribution (cult_status);
CREATE INDEX distribution_is_cultivated_taxon_idx ON distribution (is_cultivated_taxon);

CREATE INDEX cache_family_idx ON cache (family);
CREATE INDEX cache_genus_idx ON cache (genus);
CREATE INDEX cache_species_idx ON cache (species);
CREATE INDEX cache_country_idx ON cache (country);
CREATE INDEX cache_state_province_idx ON cache (state_province);
CREATE INDEX cache_county_parish_idx ON cache (county_parish);
CREATE INDEX cache_state_province_full_idx ON cache (state_province_full);
CREATE INDEX cache_county_parish_full_idx ON cache (county_parish_full);
CREATE INDEX cache_poldiv_full_idx ON cache (poldiv_full);
CREATE INDEX cache_poldiv_type_idx ON cache (poldiv_type);

CREATE INDEX observation_job_idx ON observation (job);
CREATE INDEX observation_batch_idx ON observation (batch);
CREATE INDEX observation_family_idx ON observation (family);
CREATE INDEX observation_genus_idx ON observation (genus);
CREATE INDEX observation_species_idx ON observation (species);
CREATE INDEX observation_country_idx ON observation (country);
CREATE INDEX observation_state_province_idx ON observation (state_province);
CREATE INDEX observation_county_parish_idx ON observation (county_parish);
CREATE INDEX observation_state_province_full_idx ON observation (state_province_full);
CREATE INDEX observation_county_parish_full_idx ON observation (county_parish_full);
CREATE INDEX observation_poldiv_full_idx ON observation (poldiv_full);
CREATE INDEX observation_poldiv_type_idx ON observation (poldiv_type);
CREATE INDEX observation_native_status_country_idx ON observation (native_status_country);
CREATE INDEX observation_native_status_state_province_idx ON observation (native_status_state_province);
CREATE INDEX observation_native_status_county_parish_idx ON observation (native_status_county_parish);
CREATE INDEX observation_native_status_idx ON observation (native_status);
CREATE INDEX observation_native_status_reason_idx ON observation (native_status_reason);
CREATE INDEX observation_native_status_sources_idx ON observation (native_status_sources);
CREATE INDEX observation_isIntroduced_idx ON observation (isIntroduced);
CREATE INDEX observation_isCultivatedNSR_idx ON observation (isCultivatedNSR);
CREATE INDEX observation_is_cultivated_taxon_idx ON observation (is_cultivated_taxon);
CREATE INDEX observation_is_in_cache_idx ON observation (is_in_cache);


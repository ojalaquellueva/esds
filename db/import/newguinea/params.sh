#!/bin/bash

##############################################################
# Source-specific parameters
##############################################################

# Names of raw data file(s)
data_raw="newGuinea_checklist.csv"
#data_raw="newGuinea_checklist_sample.csv"

# Name of main raw data tables
# Should be $src"_raw" unless >1 table
# Requires param $src set by master script
# Note conversion to lowercase table name in case source name contains CAPS
tbl_raw=$src"_raw"
tbl_raw=`echo "$tbl_raw" | tr '[:upper:]' '[:lower:]'`
tbl_raw_final=$tbl_raw"_final"

# Comprehensiveness of this source. Two options:
# 	1: comprehensive. Includes all species from focal region in 
# 		focal taxon. Absence from list may indicates non-native species
# 	0: selective, not comprehensive. Not all taxa in region(s) included, 
# 		absence not interpretable
# This list must be marked non-comprehensive, because it
# includes part of Indonesia. Marking it comprehensive would result in
# species from other parts of Indonesia being marked as introduced, even
# if native.
is_comprehensive=0;

# Regional scope (political division level) of this source. 
# For comprehensive sources, lower political divisions will also be treated
# as comprehensive, but higher political divisions will not. For example, 
# for a comprehensive checklist at the county level, species not on the list
# can be treated as non-native at the county level. However, at the state 
# and country level, only presences can be interpreted. 
# Three options:
#		country
#		state_province
# 		county_parish
regional_scope="country";

# Taxonomic scope
#	Highest taxonomic group encompassed by this source. Can be left blank.
#	In general, this should be "tracheophytes", "embryophytes", "bryophytes",
# 	but can also be a family if this is a monographic. Currently not used;
#	Would need to detect major higher taxon to use this information.
taxonomic_scope="tracheophytes";
#$taxonomic_scope="";

# Longer, more descriptive name for source
# Can have spaces; not used in any scripts
# after adding to table `source`
source_name_full="Flora of New Guinea";

# Primary url for this source (optional)
source_url="https:#www.nature.com/articles/s41586-020-2549-5";	

# bibtext formatted citation for thsi source
source_citation="$(cat <<-EOF
@article{camara2020new,
  title={New Guinea has the world’s richest island flora},
  author={C{\'a}mara-Leret, Rodrigo and Frodin, David G and Adema, Frits and Anderson, Christiane and Appelhans, Marc S and Argent, George and Guerrero, Susana Arias and Ashton, Peter and Baker, William J and Barfod, Anders S and others},
  journal={Nature},
  pages={1--5},
  year={2020},
  publisher={Nature Publishing Group}
}
EOF
)"

# Person who provided access to source (optional)
source_contact_name="";
source_contact_email="";

# Date accessed
# yyyy-mm-dd format
date_accessed="2020-08-18";

# Short list of regions covered by this source, to 250 characters
focal_regions="Island of New Guinea and neighbouring non-oceanic islands";

# List of countries for which this source provides comprehensive
# checklists. Spellings MUST agree with spellings in table country.
# Leave empty if none. Enter names in single quotes separated by
# commas: "'countryA','countryB','countryC'" 
# Do NOT include Indonesia for this source, only Papua New Guinea should
# be considered comprehensive for the entire country
# Also not that comprehensive list states are prepared empirically by 
# extracting all country+state combinations from database. See script
# prepare cclist_states.inc for details.
cclist_countries="
'Papua New Guinea'
";

# Extract list of comprehensive checklist states from raw data?
# Set to true ("t") only if coverage is comprehensive for ALL state-level 
# political divisions in raw data (=GADM admin_1)
# Set to false ("f") or any other value to skip this step
extract_cclist_states="t"

# Replace previous records for this source?
# VERY IMPORTANT
# Set=true to replace all previous records for this source.
# Set=false to keep existing records (name+author) and add new records only.
replace=true;

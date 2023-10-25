#!/bin/bash

#########################################################################
# Purpose: Import checklist data for current source
#########################################################################

################################
# Comment tags & exit command
################################

#### COMMENT BLOCK START ###
# echo "WARNING: portions of script `basename "$BASH_SOURCE"` commented out!"
## Other temporary code to be executed before comment block
## Start comment block
# : <<'COMMENT_BLOCK_xxx'

## End comment block
# COMMENT_BLOCK_xxx
## Temporary code to be executed after comment block
#### COMMENT BLOCK END ###

## Echo current script and exit
# echo "EXITING script `basename "$BASH_SOURCE"`"; exit 0

######################################################
# Set parameters, load functions & confirm operation
# 
# Loads local parameters only if called by master script.
# Otherwise loads all parameters, functions and options
######################################################

# Get local working directory
DIR_LOCAL="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR_LOCAL" ]]; then DIR_LOCAL="$PWD"; fi

# $local = name of this file
# $local_basename = name of this file minus ='.sh' extension
# $local_basename should be same as containing directory, as  
# well as local data subdirectory within main data directory, 
# if local data directory needed
local=`basename "${BASH_SOURCE[0]}"`
local_basename="${local/.sh/}"

# Load local params file
source "${DIR_LOCAL}/params.sh"

#########################################################################
# Main
#########################################################################

echoi $e "Source='$src'"

######################################################
# Import raw data
######################################################

echoi $e -n "- Creating raw data tables..."

# # Execute create raw tables SQL script in generic import directory
# echoi $e -n "-- Generic..."
# PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR/import/general/sql/create_raw.sql
# source "$DIR/includes/check_status.sh"

# Execute create raw tables SQL script in source import directory
#echoi $e -n "-- Source-specific tables..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v tbl_raw=$tbl_raw -v tbl_raw_final="${tbl_raw}_final" -f $DIR_LOCAL/sql/create_raw_data_tables.sql
source "$DIR/../includes/check_status.sh"

echoi $e "- Importing raw data:"
# Data
datafile=$data_raw
echoi $e -n "-- File \"$datafile\" --> table \"$tbl_raw\"..."

#echoi $e -n "--- Importing data..."
# Import full file
sql="\COPY $tbl_raw FROM '${DB_DATA_DIR}/${src}/${datafile}' with csv header "
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP -q -c "$sql"
source "$DIR/../includes/check_status.sh"

######################################################
# Basic corrections to raw data
######################################################

echoi $e -n "-- Setting empty strings to null..."
sql="SELECT f_empty2null('"$tbl_raw"'); "
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP -q -c "$sql" &> /dev/null
source "$DIR/../includes/check_status.sh"

######################################################
# Split raw data into component regions
######################################################

echoi $e -n "- Extracting country and state-level data to table \"$tbl_raw_final\"..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v tbl_raw=$tbl_raw -v tbl_raw_final=$tbl_raw_final -f $DIR_LOCAL/sql/load_raw_final.sql
source "$DIR/../includes/check_status.sh"

######################################################
# Standardize raw data
######################################################

echoi $e "- Standaridizing raw data:"

echoi $e -n "- Extracting infraspecific rank indicators..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v tbl_raw_final=$tbl_raw_final -f $DIR_LOCAL/sql/infer_rank.sql
source "$DIR/../includes/check_status.sh"

echoi $e -n "- Standardizing taxon ranks..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v tbl_raw_final=$tbl_raw_final -f $DIR_LOCAL/sql/standardize_rank.sql
source "$DIR/../includes/check_status.sh"

echoi $e -n "- Indexing raw data table..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v tbl_raw_final=$tbl_raw_final -f $DIR_LOCAL/sql/index_raw_final.sql
source "$DIR/../includes/check_status.sh"

######################################################
# Load raw checklist data to staging
######################################################

echoi $e "- Loading raw checklist data to staging table:"

# Note path to generic script in main sql folder
echoi $e -n "- Creating table \"distribution_staging\"..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_distribution_staging.sql
source "$DIR/../includes/check_status.sh"

# Using generic version as raw data already standardized
echoi $e -n "- Loading checklist data to staging table..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v tbl_raw_generic=$tbl_raw_final -v src=$src -f $DIR/sql/load_distribution_staging.sql
source "$DIR/../includes/check_status.sh"

echoi $e -n "- Indexing staging table..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/distribution_staging_create_indexes.sql
source "$DIR/../includes/check_status.sh"

######################################################
# Load checklist region metadata to staging
######################################################

echoi $e "- Loading checklist metadata to staging table:"

echoi $e -n "-- Creating table \"poldiv_source_staging\"..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_poldiv_source_staging.sql
source "$DIR/../includes/check_status.sh"

echoi $e -n "-- Loading comprehensive checklists countries..."
if [[ "$cclist_countries" == "" ]]; then
	cclist_countries_inlist="'arbitrarynonmatchingvalue'";
else
	cclist_countries_inlist=$cclist_countries;
fi
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v src=$src -v source_name_full="${source_name_full}" -v cclist_countries_inlist="${cclist_countries_inlist}" -f $DIR/sql/load_poldiv_source_staging_countries.sql
source "$DIR/../includes/check_status.sh"

echoi $e -n "-- Loading comprehensive checklist states"

if [[ "$cclist_states_from_country" == "t" ]]; then
	echoi $e -n " from list..."
	PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v src=$src -v source_name_full="${source_name_full}" -v cclist_countries_inlist="${cclist_countries_inlist}" -f $DIR/sql/load_poldiv_source_staging_state_checklists_from_list.sql
	source "$DIR/../includes/check_status.sh"
elif [[ "$extract_cclist_states" == "t" ]]; then
	tbl_cclist_states="${src}_cclist_states"
	echoi $e ":"	
	echoi $e -n "--- Extracting states from raw data to table \"$tbl_cclist_states\"..."
	PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v tbl_raw_generic=$tbl_raw_final -v tbl_cclist_states=$tbl_cclist_states -f $DIR/sql/prepare_cc_list_states.sql
	source "$DIR/../includes/check_status.sh"
	
	echoi $e -n "--- Loading states to staging table..."
	PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v src=$src -v source_name_full="${source_name_full}" -v tbl_cclist_states=$tbl_cclist_states -f $DIR/sql/load_poldiv_source_staging_state_checklists_from_table.sql
	source "$DIR/../includes/check_status.sh"
else
	echoi $e "...not applicable for this source (skipping)"
fi
	
######################################################
# Clean up: delete raw data if requested
######################################################

echoi $e -n "- Cleaning up..."

if [[ "$raw_data_action" == "drop" ]]; then
	echoi $e -n "dropping raw data..."
	PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v src=$src  -f $DIR/sql/drop_raw.sql
	source "$DIR/../includes/check_status.sh"
elif [[ "$raw_data_action" == "move" ]]; then
	echoi $e -n "moving raw data to schema \"staging\"..."
	PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v src=$src  -f $DIR/sql/move_raw.sql
	source "$DIR/../includes/check_status.sh"
else
	echoi $e "keeping raw data"
fi
	

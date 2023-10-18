#!/bin/bash

#########################################################################
# Purpose: Import checklist data for current source
#########################################################################

# Comment-block tags - Use for all temporary comment blocks

#### TEMP ####
# echo "WARNING: portions of script `basename "$BASH_SOURCE"` commented out!"
## Other temporary code to be executed before comment block
## Start comment block
# : <<'COMMENT_BLOCK_xxx'

## End comment block
# COMMENT_BLOCK_xxx
## Temporary code to be executed after comment block
#### TEMP ####

## Exit all scripts
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

#########################################################################
# Main
#########################################################################

echoi $e "Importing source '$src'"

######################################################
# Import raw data
######################################################

echoi $e "- Creating raw data tables:"
# Execute create raw tables SQL script in generic import directory
echoi $e -n "-- Generic..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR/import/sql/create_raw.sql
source "$DIR/includes/check_status.sh"

# Execute create raw tables SQL script in source import directory
echoi $e -n "-- Source-specific..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v tbl_raw=$tbl_raw -f $DIR_LOCAL/sql/create_raw.sql
source "$DIR/includes/check_status.sh"

echoi $i "- Importing raw data to table:"

# Data
tbl=$tbl_raw
datafile=$data_raw
echoi $i "-- '$datafile' --> $tbl:"

echoi $i -n "--- Importing data..."
	# Import full file
	sql="\COPY $tbl FROM '${data_dir_local}/${datafile}' WITH (FORMAT 'text', NULL '');"
	PGOPTIONS='--client-min-messages=warning' psql $db_private $user -q << EOF
	\set ON_ERROR_STOP on
	SET search_path TO $dev_schema;
	$sql
EOF
source "$DIR/includes/check_status.sh"

######################################################
# Corrections done on raw data, if any
######################################################

# Add additional validation & scrubbing fields to raw data table
echoi $e -n "- Altering raw data table structure..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v tbl_raw=$tbl_raw -f $DIR_LOCAL/sql/alter_raw.sql
source "$DIR/includes/check_status.sh"

echoi $e "- Processing dates:"

echoi $e -n "-- Populating integer Y, M, D columns..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v tbl_raw=$tbl_raw -f $DIR_LOCAL/sql/populate_raw_ymd.sql
source "$DIR/includes/check_status.sh"

##################################
# Correct integer Y, M, D columns 
# for eventDate
##################################
y_col="eventdate_yr"			# Name of integer year column
m_col="eventdate_mo"			# Name of integer month column
d_col="eventdate_dy"				# Name of integer day column
y_idx=$tbl"_"$y_col"_idx"	# Name of index on integer year column
m_idx=$tbl"_"$m_col"_idx"	# Name of index on integer month column
d_idx=$tbl"_"$d_col"_idx"	# Name of index on integer day column

echoi $e -n "-- Correcting dates from column \"eventDate\"..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v tbl=$tbl_raw -v y_col=$y_col -v m_col=$m_col -v d_col=$d_col -v y_idx=$y_idx -v m_idx=$m_idx -v d_idx=$d_idx -f $DIR/import/sql/correct_ymd.sql
source "$DIR/includes/check_status.sh"

##################################
# Correct integer Y, M, D columns 
# for dateidentified
##################################
y_col="dateidentified_yr"			# Name of integer year column
m_col="dateidentified_mo"			# Name of integer month column
d_col="dateidentified_dy"				# Name of integer day column
y_idx=$tbl"_"$y_col"_idx"	# Name of index on integer year column
m_idx=$tbl"_"$m_col"_idx"	# Name of index on integer month column
d_idx=$tbl"_"$d_col"_idx"	# Name of index on integer day column

echoi $e -n "-- Correcting dates from column \"dateIdentified\"..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v tbl=$tbl_raw -v y_col=$y_col -v m_col=$m_col -v d_col=$d_col -v y_idx=$y_idx -v m_idx=$m_idx -v d_idx=$d_idx -f $DIR/import/sql/correct_ymd.sql
source "$DIR/includes/check_status.sh"

echoi $e -n "- Indexing raw data..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v tbl_raw=$tbl_raw -f $DIR_LOCAL/sql/index_raw.sql
source "$DIR/includes/check_status.sh"

######################################################
# Load raw data to staging tables
######################################################

echoi $e -n "- Creating staging tables..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR/import/sql/create_staging.sql
source "$DIR/includes/check_status.sh"

echoi $e "- Loading staging tables:"

echoi $e -n "-- vfoi_staging..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v src=$src -v tbl_raw=$tbl_raw -v psrc_list="$psrc_list" -f $DIR_LOCAL/sql/load_staging_vfoi.sql
source "$DIR/includes/check_status.sh"

echoi $e -n "-- datasource_staging..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v tbl_raw=$tbl_raw -f $DIR_LOCAL/sql/load_datasource_staging.sql
source "$DIR/includes/check_status.sh"

echoi $e -n "- Populating FK to datasource_staging..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v tbl_raw=$tbl_raw -f $DIR_LOCAL/sql/update_datasource_fks.sql
source "$DIR/includes/check_status.sh"

echoi $e -n "- Dropping raw data indexes..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v tbl_raw=$tbl_raw -f $DIR_LOCAL/sql/drop_indexes_raw.sql
source "$DIR/includes/check_status.sh"



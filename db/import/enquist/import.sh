#!/bin/bash

#########################################################################
# Purpose: Import new data, injecting directly into analytical database
#
# Main script imports all new sources. To import a source separately, 
# 	see script for that source (import_[source_name].sh, also in this
# 	directory.
#
# Authors: Brad Boyle (bboyle@email.arizona.edu)
#########################################################################

: <<'COMMENT_BLOCK_x'
COMMENT_BLOCK_x

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

# Set parent directory if running independently
if [ -z ${master+x} ]; then
	DIR=$DIR_LOCAL"/.."
fi

# Load startup script for local files
# Sets remaining parameters and options, and issues confirmation
# and startup messages
source "$DIR/includes/startup_local.sh"	
	
#########################################################################
# Main
#########################################################################

echoi $e "Executing module '$pname_local'"

######################################################
# Import raw data
######################################################

echoi $e "- Creating raw data tables:"
echoi $e -n "-- Generic..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR/import/sql/create_raw.sql
source "$DIR/includes/check_status.sh"

echoi $e -n "-- Source-specific..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/create_raw.sql
source "$DIR/includes/check_status.sh"

echoi $i "- Importing raw data to table:"

# Data
tbl="chilesp_raw"
datafile=$data_raw
echoi $i -n "-- '$datafile' --> $tbl..."

if [ $use_limit = "true" ]; then 
	# Import subset of records (development only)
	head -n $recordlimit $data_dir_local/$datafile | psql $db_private $user -q -c "COPY ${dev_schema}.${tbl} FROM STDIN DELIMITER ',' CSV NULL AS 'NULL' HEADER"
else
	# Import full file
	sql="\COPY $tbl FROM '${data_dir_local}/${datafile}' DELIMITER ',' CSV NULL AS 'NULL' HEADER;"
	PGOPTIONS='--client-min-messages=warning' psql $db_private $user -q << EOF
	\set ON_ERROR_STOP on
	SET search_path TO $dev_schema;
	$sql
EOF
fi
source "$DIR/includes/check_status.sh"

# Metadata
tbl="datasource_raw"
datafile=$metadata_raw
echoi $i -n "-- '$datafile' --> $tbl..."

# Import full file
sql="\COPY $tbl FROM '${data_dir_local}/${datafile}' DELIMITER ',' CSV NULL AS 'NULL';"
PGOPTIONS='--client-min-messages=warning' psql $db_private $user -q << EOF
\set ON_ERROR_STOP on
SET search_path TO $dev_schema;
$sql
EOF
source "$DIR/includes/check_status.sh"

######################################################
# Corrections that must be done on raw data, if any
######################################################

echoi $e "- Correcting raw data:"

echoi $e -n "-- Creating integer Y, M, D columns..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/correct_raw_ymd.sql
source "$DIR/includes/check_status.sh"

echoi $e -n "-- Setting empty strings to null..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR_LOCAL/sql/correct_raw.sql
source "$DIR/includes/check_status.sh"

# Generic operation correct_ymd.sql requires following parameters:
tbl="chilesp_raw"	# Name of raw table 
y_col="yr"			# Name of integer year column
m_col="mo"			# Name of integer month column
d_col="dy"			# Name of integer day column
y_idx=$tbl"_"$y_col"_idx"	# Name of index on integer year column
m_idx=$tbl"_"$m_col"_idx"	# Name of index on integer month column
d_idx=$tbl"_"$d_col"_idx"	# Name of index on integer day column

echoi $e -n "-- Correcting dates..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v tbl=$tbl -v y_col=$y_col -v m_col=$m_col -v d_col=$d_col -v y_idx=$y_idx -v m_idx=$m_idx -v d_idx=$d_idx -f $DIR/import/sql/correct_ymd.sql
source "$DIR/includes/check_status.sh"

######################################################
# Load raw data to staging tables
######################################################

echoi $e -n "- Creating staging tables..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR/import/sql/create_staging.sql
source "$DIR/includes/check_status.sh"

echoi $e "- Loading staging tables:"

echoi $e -n "-- datasource_staging..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -f $DIR/import/sql/load_staging_datasource.sql
source "$DIR/includes/check_status.sh"

echoi $e -n "-- vfoi_staging..."
PGOPTIONS='--client-min-messages=warning' psql -U $user -d $db_private --set ON_ERROR_STOP=1 -q -v sch=$dev_schema -v src=$src -f $DIR_LOCAL/sql/load_staging_vfoi.sql
source "$DIR/includes/check_status.sh"

######################################################
# Correct data in staging tables
######################################################

echoi $e "- Correcting staging tables:"

echoi $e -n "-- view_full_occurrence_individual..."
# Insert corrections here
echoi $e "no corrections needed"

######################################################
# Report total elapsed time and exit if running solo
######################################################

if [ -z ${master+x} ]; then source "$DIR/includes/finish.sh"; fi



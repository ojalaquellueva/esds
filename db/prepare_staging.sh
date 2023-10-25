#!/bin/bash

#########################################################################
# Purpose: Prepare generic fields in staging table for current source
#
# Sourced by esds.sh (not a standalone script) 
#########################################################################

echoi $e "Preparing staging table:"

echoi $e -n "- Standardizing native status codes......"
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/standardize_native_status.sql
source "$DIR/../includes/check_status.sh"

echoi $e -n "- Setting NULL poldivs to empty string..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/staging_poldivs_null2empty.sql
source "$DIR/../includes/check_status.sh"

echoi $e "- Adding missing parent taxa:"

echoi $e -n "-- Adding missing species..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v src="$src" -f $DIR/sql/staging_add_species.sql
source "$DIR/../includes/check_status.sh"

echoi $e -n "-- Adding missing genera..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v src="$src" -f $DIR/sql/staging_add_genus.sql
source "$DIR/../includes/check_status.sh"

echoi $e -n "-- Adding missing families..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v src="$src" -f $DIR/sql/staging_add_family.sql
source "$DIR/../includes/check_status.sh"

echoi $e -n "- Restoring poldiv NULLs..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/staging_poldivs_restore_nulls.sql
source "$DIR/../includes/check_status.sh"


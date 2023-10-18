#!/bin/bash

#########################################################################
# Purpose: Creates and populates Exotic Species Detection Service 
# 	database (ESDS) 
#
# Usage:	./esds_db.sh [-q] [-v] [-a] [-m [EMAIL_ADDRESSES]]
#
# Options:
# 	-q	Quiet mode
#	-v	Verbose mode
#	-a	Append to log (starts new log if not used, replacing previous)
#	-m	Send email notifications of process start and process end or fail.
#		if optional argument EMAIL_ADDRESSES is omitted will attempt to
#		use default email ($EMAIL_DEF) from params file, if set. Separate
#		multiple email addresses with commas. If EMAIL_ADDRESSES omitted, 
#		"-m" MUST be the last parameter.
#
# Requirements:
# 	1. Postgres database gadm on local filesystem (see repository 
#		https://github.com/ojalaquellueva/gadm)
#
# Authors: Brad Boyle (bboyle@email.arizona.edu)
# Date created: 31 January 2023
#########################################################################

#echo "WARNING: Sections of this script are commented out!"
: <<'COMMENT_BLOCK_x'
COMMENT_BLOCK_x

#echo "EXITING script `basename "$BASH_SOURCE"`"; exit 0

######################################################
# Set basic parameters, functions and options
######################################################


# Enable the following for strict debugging only:
#set -e

# The name of this file. Needed by sourced files.
master=`basename "$0"`

# Get current working directory
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi

# Load local parameters file
# MUST be in same directory as this file
source "${DIR}/params.sh"

# Load functions and get command-line options from includes directory
#source "$INCLUDES_DIR/startup_master.sh"
source "${INCLUDES_DIR}/functions.sh"

# # Pseudo error log, to absorb screen echo during import
# tmplog="/tmp/tmplog.txt"
# echo "Error log
# " > $tmplog

###########################################################
# Get options
#   -q  Quiet mode. Suppresses screen echo.
#   -m	Send email notification of error of completion. If
#		not followed by email, uses default email from 
#		params file.
#	-a	Append to existing logfile (=$glogfile). If not 
#		provided, default is start new (replace old if exists)
###########################################################

# Set defaults
quiet=false						# Echo on by default
e="true"						# Echo on; for compatibility with function echoi()
verbose=false					# Minimal progress output
notify=false					# Don't send email notifications
appendlog=false				# Append to existing logfile 

# Get options
while [ "$1" != "" ]; do
    case $1 in
        -v | --verbose )		verbose=true
        						;;
        -q | --quiet )			quiet=true
        						e="false"
        						;;
        -m | --mailto )     	notify="true"
								shift
								email=$1
								;;
        -a | --appendlog )		appendlog=true 		# Start new logfile, 
        						;;
        * )                     echo "invalid option!"; exit 1
    esac
    shift
done

if [ "$email" == "" ]; then
	if [[ ! "$EMAIL_DEF" == "" ]]; then 
		# Use default if notification requested but no
		# email parameter supplied on command line
		email=$EMAIL_DEF
	else
		# Reset notify to false if no default
		# email supplied
		notify=false
	fi
fi

######################################################
# Custom confirmation message. 
# Will only be displayed if -s (silent) option not used.
######################################################

curr_user=$(whoami)

db_user_admin_disp=$USER_ADMIN
if [[ "$USER_ADMIN" == "" ]]; then
	db_user_admin_disp="[none]"
fi

db_user_disp=$USER
if [[ "$USER" == "" ]]; then
	db_user_disp="[none]"
fi

db_user_read_disp=$USER_READ
if [[ "$USER_READ" == "" ]]; then
	db_user_read_disp="[none]"
fi

email_disp="$email"
if ! $notify; then
	email_disp="[notifications off]"
fi

src_disp=""
for src in $sources; do
	src_disp=$src_disp", "$src
done
shopt -s extglob
src_disp=${src_disp%, }
src_disp=${src_disp#, }

# Reset confirmation message
msg_conf="$(cat <<-EOF

Run process '$pname' using the following parameters: 

${APP} DB:			$DB_APP
GNRS DB:			$DB_GNRS
GADM DB:			$DB_GADM
Geonames DB:			$DB_GEONAMES
Base directory:			$BASE_DIR
DB data directory:		$DB_DATA_DIR
Current user:			$curr_user
Admin db creator:		$db_user_admin_disp
DB user:			$db_user_disp
Additional read-only DB user:	$db_user_read_disp
Notifications to:		$email_disp
Checklist sources: 		$src_disp

EOF
)"		
confirm "$msg_conf"

# Start time, send mail if requested and echo begin message
source "$INCLUDES_DIR/start_process2.sh"  

#########################################################################
# Main
#########################################################################

# Run pointless command to trigger sudo password request, 
# needed below. Should remain in effect for all
# sudo commands in this script, regardless of sudo timeout
sudo pwd >/dev/null



echo "WARNING: Sections of this script are commented out!"
: <<'COMMENT_BLOCK_1'


############################################
# Create database in admin role & reassign
# to principal non-admin user of database
############################################

# Warn to drop manually if db already exists. This is safer.
if psql -lqt | cut -d \| -f 1 | grep -qw "$DB_APP"; then
	# Reset confirmation message
	msg="Database '$DB_APP' already exists! Please drop first."
	echo $msg; exit 1
fi

echoi $e -n "Creating database '$DB_APP'..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -q -c "CREATE DATABASE $DB_APP" 
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "Changing owner to '$USER'..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -q -c "ALTER DATABASE $DB_APP OWNER TO ${USER}" 
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "Granting permissions..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql -q << EOF
\set ON_ERROR_STOP on
REVOKE CONNECT ON DATABASE $DB_APP FROM PUBLIC;
GRANT CONNECT ON DATABASE $DB_APP TO $USER;
GRANT CONNECT ON DATABASE $DB_APP TO $USER_READ;
GRANT ALL PRIVILEGES ON DATABASE $DB_APP TO $USER;
\c $DB_APP
GRANT USAGE ON SCHEMA public TO $USER_READ;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO $USER_READ;
EOF
source "$INCLUDES_DIR/check_status.sh" 

echoi $e "Installing extensions:"

# POSTGIS
echoi $e -n "- postgis..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP -q << EOF
\set ON_ERROR_STOP on
DROP EXTENSION IF EXISTS postgis;
CREATE EXTENSION postgis;
EOF
source "$INCLUDES_DIR/check_status.sh" 

echoi $e -n "- fuzzystrmatch..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP -q << EOF
\set ON_ERROR_STOP on
DROP EXTENSION IF EXISTS fuzzystrmatch;
CREATE EXTENSION fuzzystrmatch;
EOF
source "$INCLUDES_DIR/check_status.sh" 

# For trigram fuzzy matching
echoi $e -n "- pg_trgm..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP -q << EOF
\set ON_ERROR_STOP on
DROP EXTENSION IF EXISTS pg_trgm;
CREATE EXTENSION pg_trgm;
EOF
source "$INCLUDES_DIR/check_status.sh" 

# For generating unaccented versions of text
echoi $e -n "- unaccent..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP -q << EOF
\set ON_ERROR_STOP on
DROP EXTENSION IF EXISTS unaccent;
CREATE EXTENSION unaccent;
EOF
source "$INCLUDES_DIR/check_status.sh" 

############################################
# Import GNRS tables
############################################

echoi $e "Importing political division tables from DB $DB_GNRS:"

echoi $e -n "- Dropping existing target tables, if any..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql  -d $DB_APP --set ON_ERROR_STOP=1 -q -c "DROP TABLE IF EXISTS meta, country, state_province, county_parish CASCADE" 
source "$INCLUDES_DIR/check_status.sh"  

# Dump tables from source database
echoi $e -n "- Creating dumpfile of tables from DB ${DB_GNRS}..."
dumpfile="/tmp/gnrs_extract.sql"
sudo -u postgres pg_dump --no-owner -t meta -t country -t state_province -t county_parish "$DB_GNRS" > $dumpfile
source "$INCLUDES_DIR/check_status.sh"  

# Import table from dumpfile to target db & schema
echoi $e -n "- Importing tables from dumpfile..."
PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 $DB_APP < $dumpfile > /dev/null > "/tmp/tmplog.txt"
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "- Renaming \"meta\" to \"meta_gnrs\"..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql  -d $DB_APP --set ON_ERROR_STOP=1 -q -c "ALTER TABLE meta RENAME TO meta_gnrs" 
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "- Removing dumpfile..."
rm $dumpfile
source "$INCLUDES_DIR/check_status.sh"  

############################################
# Import GADM spatial tables
############################################

echoi $e "Importing spatial tables from DB $DB_GADM:"

# echoi $e -n "- Dropping existing target tables, if any..."
# sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql  -d $DB_APP --set ON_ERROR_STOP=1 -q -c "DROP TABLE IF EXISTS meta, gadm CASCADE" 
# source "$INCLUDES_DIR/check_status.sh"  

# Dump tables from source database
echoi $e -n "- Creating dumpfile of tables from DB ${DB_GADM}..."
dumpfile="/tmp/gadm_extract.sql"
sudo -u postgres pg_dump --no-owner -t meta -t gadm "$DB_GADM" > $dumpfile
source "$INCLUDES_DIR/check_status.sh"  

# Import table from dumpfile to target db & schema
echoi $e -n "- Importing tables from dumpfile..."
PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 $DB_APP < $dumpfile > /dev/null > "/tmp/tmplog.txt"
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "- Renaming \"meta\" to \"meta_gadm\"..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql  -d $DB_APP --set ON_ERROR_STOP=1 -q -c "ALTER TABLE meta RENAME TO meta_gadm" 
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "- Removing dumpfile..."
rm $dumpfile
source "$INCLUDES_DIR/check_status.sh"  

############################################
# Create core data tables
############################################

echoi $e -n "Creating core application tables..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_core_tables.sql
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "Dropping indexes on core tables..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/drop_indexes_core_tables.sql
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "Indexing core tables..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_indexes_core_tables.sql
source "$INCLUDES_DIR/check_status.sh"  

############################################
# Import political division tables from 
# GNRS database
############################################

echoi $e "Importing political division tables from DB $DB_GNRS:"

echoi $e -n "- Dropping existing tables, if any..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql  -d $DB_APP --set ON_ERROR_STOP=1 -q -c "DROP TABLE IF EXISTS country, country_name, state_province, state_province_name, county_parish, county_parish_name CASCADE" 
source "$INCLUDES_DIR/check_status.sh"  

# Dump tables from source database
echoi $e -n "- Creating dumpfile of tables from DB ${DB_GNRS}..."
dumpfile="/tmp/gnrs_extract.sql"
sudo -u postgres pg_dump --no-owner -t country -t country_name -t state_province -t state_province_name -t county_parish -t county_parish_name "$DB_GNRS" > $dumpfile
source "$INCLUDES_DIR/check_status.sh"  

# Import table from dumpfile to target db & schema
echoi $e -n "- Importing tables from dumpfile..."
PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 $DB_APP < $dumpfile > /dev/null > "/tmp/tmplog.txt"
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "- Removing dumpfile..."
rm $dumpfile
source "$INCLUDES_DIR/check_status.sh"  




COMMENT_BLOCK_1


############################################
# Import genus-family lookup table from 
# TNRS database
#
# Assumes:
#   * zip archive gf_lookup.txt.zip in dir data/
#   * Archive unzips to gf_lookup.txt
############################################

echoi $e "Importing genus-family lookup table:"

gf_file="gf_lookup.txt"
gf_file_compressed=$gf_file".zip"

echoi $e -n "- Creating table..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_gf_lookup.sql
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "- Uncompressing file..."
unzip -q -o data/${gf_file_compressed} -d data
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "- Importing data..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql  -d $DB_APP --set ON_ERROR_STOP=1 -q -c "\copy gf_lookup from 'data/${gf_file}' with delimiter E'\t' csv header" 
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "- Removing uncompressed file..."
rm data/${gf_file}
source "$INCLUDES_DIR/check_status.sh"  

echoi $e -n "- Removing sequence..."
sudo -u postgres PGOPTIONS='--client-min-messages=warning' psql  -d $DB_APP --set ON_ERROR_STOP=1 -q -c "DROP SEQUENCE IF EXISTS gf_lookup_gf_lookup_id_seq CASCADE" 
source "$INCLUDES_DIR/check_status.sh"  

############################################
# Load checklist sources
############################################

echoi $e "Importing checklist sources:"

for src in $sources; do
	echoi $e "-----------------------------------"
	echoi $e "Source=$src"
	source "$DIR/import/"$src"/import.sh"
	source "$DIR/prepare_staging/prepare_staging.sh"
	source "$DIR/load_core_db/load_core_db.sh"
done





echo "EXITING script `basename "$BASH_SOURCE"`"; exit 0





############################################
# Create output data dictionary
############################################

echoi $e -n "Creating output data dictionary..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/dd_output.sql
source "$INCLUDES_DIR/check_status.sh"

###########################################
# Populate metadata tables
############################################

echoi $e -n "Creating metadata tables..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -f $DIR/sql/create_metadata_tables.sql
source "$INCLUDES_DIR/check_status.sh"

echoi $e "Loading metadata tables:"

echoi $e -n "- meta..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v VERSION="$VERSION" -v DB_VERSION="$DB_VERSION" -v VERSION_COMMENTS="$VERSION_COMMENTS" -f $DIR/sql/load_meta.sql
source "$INCLUDES_DIR/check_status.sh"

echoi $e -n "- source..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP --set ON_ERROR_STOP=1 -q -v VERSION="$VERSION" -v DB_VERSION="$DB_VERSION" -f $DIR/sql/load_source.sql
source "$INCLUDES_DIR/check_status.sh"

echoi $e -n "- collaborator..."
sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql $DB_APP --set ON_ERROR_STOP=1 -q <<EOT
copy collaborator(collaborator_name, collaborator_name_full, collaborator_url, description, logo_path) from '${DATA_DIR}/${CSV_COLLABORATORS}' CSV HEADER;
EOT
source "$INCLUDES_DIR/check_status.sh"

echoi $e -n "- Dropping source-specific metadata tables..."
PGOPTIONS='--client-min-messages=warning' psql -d $DB_APP -q << EOF
\set ON_ERROR_STOP on
DROP TABLE IF EXISTS gadm_meta;
DROP TABLE IF EXISTS geonames_meta;
EOF
echoi $e "done"

############################################
# Set ownership and permissions
# 
# Performed after either operation
############################################

if [ "$USER_ADMIN" != "" ]; then
	echoi $e "Changing database ownership and permissions:"

	echoi $e -n "- Changing DB owner to '$USER_ADMIN'..."
	sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql --set ON_ERROR_STOP=1 -q -c "ALTER DATABASE $DB_APP OWNER TO $USER_ADMIN" 
	source "$INCLUDES_DIR/check_status.sh"  

	echoi $e -n "- Granting permissions..."
	sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q <<EOF
	\set ON_ERROR_STOP on
	REVOKE CONNECT ON DATABASE $DB_APP FROM PUBLIC;
	GRANT CONNECT ON DATABASE $DB_APP TO $USER_ADMIN;
	GRANT ALL PRIVILEGES ON DATABASE $DB_APP TO $USER_ADMIN;
EOF
	echoi $e "done"

	echoi $e "- Transferring ownership of non-postgis relations to user '$USER_ADMIN':"
	# Note: views not changed as all at this point are postgis relations

	echoi $e -n "-- Tables..."
	for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname='public' and tableowner<>'postgres';" $DB_APP` ; do  sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q -c "alter table \"$tbl\" owner to $USER_ADMIN" $DB_APP ; done
	source "$INCLUDES_DIR/check_status.sh"  

	echoi $e -n "-- Sequences..."
	for tbl in `psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" $DB_APP` ; do  sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q -c "alter sequence \"$tbl\" owner to $USER_ADMIN" $DB_APP ; done
	source "$INCLUDES_DIR/check_status.sh"  
fi

if [[ ! "$USER_READ" == "" ]]; then
	echoi $e -n "- Granting read access to \"$USER_READ\"..."
	sudo -Hiu postgres PGOPTIONS='--client-min-messages=warning' psql -q <<EOF
	\set ON_ERROR_STOP on
	REVOKE CONNECT ON DATABASE $DB_APP FROM PUBLIC;
	GRANT CONNECT ON DATABASE $DB_APP TO $USER_READ;
	\c $DB_APP
	GRANT USAGE ON SCHEMA public TO $USER_READ;
	GRANT SELECT ON ALL TABLES IN SCHEMA public TO $USER_READ;
EOF
	echoi $e "done"
fi 

######################################################
# Report total elapsed time and exit
######################################################

source "$INCLUDES_DIR/finish.sh"

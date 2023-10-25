#!/bin/bash

# Set working directory of this file
wd=$(dirname ${BASH_SOURCE[0]})

##############################################################
# Database build parameters
#
# Omit trailing slash from paths
##############################################################

# Application short code and full name
APP="ESDS"
APP_NAME="Exotic Species Detection Service"
app="${APP,,}"	# Lower case version of $APP

# Name of application database to build
DB_APP="esds_dev"

# Names of required reference databases
# Tables from these databases are imported to app DB
DB_GNRS="gnrs_2_2"		# Name of local GNRS database
DB_GEONAMES="geonames" 	# Name of local Geonames database
DB_GADM="gadm"			# Name of local GADM database

# Configuration directory path, relative to this file
# Omit trailing slash
CONFIG_DIR="${wd}/../../config"

# Load server-specific config file (SSCF)
# The SSCF sets parameter $BASE_DIR, the absolute path
# to application base directory containing all code, data 
# and documentation for this application, including the 
# code directory & repo (this one).
# Recommended location for SSCF is $BASE_DIR/config/
source "${CONFIG_DIR}/db_config.sh";

# Uncomment to echo & confirm $BASE_DIR
echo "BASE_DIR='${BASE_DIR}'"

# Default email for notifications
# Over-ridden if email supplied with -m switch on command line
EMAIL_DEF="bboyle@arizona.edu"
EMAIL_DEF="ojalaquellueva@gmail.com"

# Source codes
# Short code of each checklist source to import
# The code MUST be the same as:
# a) suffix of the import directors (e.g., import_<source_code>) AND
# b) subdirectory in the data directory in which raw data are 
# stored AND
# d) value of column source_name in table source.
# One source code per line, no commas or quotes
sources="
enquist
weakley
mab
ipane
powo
flbr
conosur
fwi
mexico
tropicos
usda
vascan
newguinea
"
sources="
newguinea
"

# Database data directory
DB_DATA_DIR="${BASE_DIR}/data/db"

# Absolute path to master includes directory
INCLUDES_DIR="${BASE_DIR}/../includes/sh"

##########################
# Handling of raw data 
# afterdatabase build
##########################

# Set to "keep" to keep all raw data tables in main schema (public)
# Set to "drop" to drop all raw data tables
# Set to "move" to move all raw data to separate schema "staging"
raw_data_action="move"

##########################
# Display/notification parameters
##########################

# Short name for this operation, for screen echo and 
# notification emails. Number suffix matches script suffix
pname="$APP"
pname_local=$pname

# General process name prefix for email notifications
pname_header_prefix="Process"

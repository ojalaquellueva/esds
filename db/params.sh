#!/bin/bash

# Set working directory of this file
wd=$(dirname ${BASH_SOURCE[0]})

##############################################################
# Application parameters
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
# The SSCF sets parameters $BASE_DIR, the absolute path
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


#################################
# You should not need to change
# the remaining parameters unless 
# you alter the default configuration
#################################

# Database data directory
DB_DATA_DIR="${BASE_DIR}/data/db"

# # User data directory relative path and name
# # GNRS will look here inside app directory for user input
# # and will write results here, unless $data_dir_local_abs
# # is set (next parameter)
# # Omit trailing slash
# data_base_dir="data/user"		
# 
# # User data directory absolute path and name
# # Use this if data directory outside root application directory
# # Comment out to use $data_base_dir (relative, above)
# # Omit trailing slash
# data_dir_local_abs="${BASE_DIR}/data/user"
# #data_dir_local_abs="/home/boyle/bien3/repos/gnrs/data/user_data"
# 
# # For backward-compatibility
# data_dir_local=$data_dir_local_abs

###################################
# Path to includes/ directory
# Choose one, comment out the other
###################################

# Absolute path to master includes directory
INCLUDES_DIR="${BASE_DIR}/../includes/sh"

# Relative path to includes directory 
# Use only if "includes" installed as Git submodule
#includes_dir="${wd}/../includes/sh"

#############################################################
# Normally shouldn't have to change remaining parameters
#############################################################

##########################
# Batch & multi-user
# parameters
##########################

# Default batch size. Recommend 10000. Input files smaller than this number
# (I.e., fewer lines) will be processed as single batch.
batch_size=10000;

##########################
# Replace user_data
##########################

# Purge user_data after each call of gnrs_batch?
# Generally good idea to avoid bloat & slow performance
clear_user_data='t'

# Clear entire user_data_table
clear_user_data_all='f'

##########################
# Subsampling parameters
# For testing with samples of input data
##########################

# 't' to limit number of records imported (for testing)
# 'f' to run full import
use_limit='f'

# Ignored if use_limit='f'
recordlimit=100000

##########################
# Set debug mode
#
# Values: t|f
# t: debug mode on
#	* clears cache and all previous user data before start
#	* echoes parameters for gnrs_batch and gnrs to file in data directory
#	* Retains user data for current run in DB for inspection
# f: debug mode off
#	* Turns off echo-params-to-file
#	* Clears user data for current run from DB after operation complete
#
# Make sure debug_clear_all='f' for production!!!
##########################

# Save debugging file of key parameters
debug_mode='f'

# Clear all user data and cache to avoid confusion with previous jobs
# TURN OFF FOR PRODUCTION!!!
debug_clear_all='f'

# Global log file
glogfile="glog"

##########################
# Display/notification parameters
##########################

# Short name for this operation, for screen echo and 
# notification emails. Number suffix matches script suffix
pname="$APP"
pname_local=$pname

# General process name prefix for email notifications
pname_header_prefix="Process"

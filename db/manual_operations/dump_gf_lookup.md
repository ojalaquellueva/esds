# Dump table gf_lookup from original NSR database to ESDS data directory

This table can be accessed via the NSR repository, but am including it here for simplicity.

```
# Move to ESDS repo data directory 
cd data

# Populate parameter values 
DB="NSRDBNAME"
USER="USERNAME"
PASSW="DBPASSWORD"

DB="nsr_2_0"
USER="boyle"
PASSW="5ten0cereu5"

# Dump table and header to this directory as tab-delimited file
echo "select * from gf_lookup" | mysql -u${USER} -p${PASSW} $DB > gf_lookup.txt

# Compress it
zip gf_lookup.txt.zip gf_lookup.txt
rm gf_lookup.txt
```
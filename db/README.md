# Build ESDS (Exotic Species Detection Service) database

Author: Brad Boyle (bboyle@email.arizona.edu)  

## Table of Contents

- [Overview](#Overview)
- [Requirements](#Requirements)
- [Usage](#Usage)

### <a name="Overview"></a>Overview

Builds Exotic Species Detection Service (ESDS) database by loading and normalizing expert synonymized checklists for political units or other geographic regions. Also loads political division data from GADM, as well as supplementary spatial information for checklist regions which are not political divisions (e.g., for national parks). 


### <a name="Requirements"></a>Requirements

Postgres databases geonames and gadm must exist on local machine. See the following separate repositories for the code that builds these databases:

https://github.com/ojalaquellueva/gadm
https://github.com/ojalaquellueva/geonames

### <a name="Usage"></a>Usage

```
$ ./esds_db.sh ./esds_db.sh [-q] [-m [EMAIL_ADDRESSES]]

```

##### Options

Option | Meaning	| Arguments | Details
------ | -----	| ----- | -----
	-q	| Quiet mode |  | Suppress all screen output
	-m	| Notify | EMAIL_ADDRESSES | Send email notifications of process start and process end or fail. Separate multiple email addresses with commas. If email argument omitted application will attempt to use default email from params file (-m MUST be the final parameter in this case).

  	
##### Tips
* For large jobs, run in unix screen with -m switch to notify of process start, stop or errors.
  	
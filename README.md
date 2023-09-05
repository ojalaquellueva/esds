# Exotic Species Detection Service (ESDS)


## Overview

Application for the detection of exotic (introduced) or cultivated occurrences of organisms in biodiversity observation data.  

Species occurrence status is determined with reference to taxonomic checklists for political divisions (countries, states, counties) or other administrative regions, such as national parks and other protected areas.

## Suggested application directory structure

```
esds/       Application base directory
|__admin/   Admin applications and documentation
|__config/  Sensitive configuration parameter files. Keep outside 
|           application code directory.
|__data/    Data base directory
|  |__db/   Application database raw reference data
|  |__user/ User data (input, output)
|__src/     Application code directory (=this repository)
	|__api/  API code directory
	|__db/   Database code directory (builds application database)
	|  |__ sql/  DB application SQL files
	|__sql/  Core application SQL files
```
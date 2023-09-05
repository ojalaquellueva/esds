# Exotic Species Detection Service (ESDS)

## Contents

[Overview](#overview)  
[Dependencies](#dependencies)  
[Required OS and software](#software)  
[Setup & configuration](#setup)  
[Usage](#usage)  
* [Input formats](#input)  
* [Commands](#commands)  
* [Output fields and examples](#output)  

<a name="overview"></a>
## Overview

Application for the detection of exotic (introduced) or cultivated occurrences of organisms in biodiversity observation data. For each submitted occurrence, returns a native status of "native", "introduced" or "unknown". Cultivated status, if known, is returned in a separate field. Thus, a cultivated occurrence can be either introduced. An example of the latter is an observation of potato (Solanum tuberosum) in Peru. The ESDS is the updated and completely refactored successor to the Native Species Resolver (NSR; https://github.com/ojalaquellueva/nsr).

The ESDS supports two alternative input types:

1. Species plus political division. Species name plus country and optional lower political divisions. This is the same as the format supported by the original NSR. Format: Genus species,country,[state_province,[county_parish]].
2. Species plus point of observation (geocoordinates). Format: Genus species,latitude,longitude. Coordinate must be in decimal format.

<a name="dependencies"></a>
## Dependencies



<a name="software"></a>
## Required OS and software




<a name="setup"></a>
## Setup & configuration

1. Create application base directory (e.g., `esds`). 
1. Create application code directory `src`
2. Clone this repo to application code directory
1. Move config and data directories and their contents outside application code directory (`src/`; this one) to create the directory structure shown below. Your application directory structure should now be as shown below.
1. Remove ".example" suffix from file name directory config
1. Modify config files as appropriate for your installation. 

#### Suggested application directory structure:

```
esds/       Application base directory
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

<a name="usage"></a>
## Usage


<a name="input"></a>
### Input formats

<a name="commands"></a>
### Commands

<a name="output"></a>
### Output fields and examples


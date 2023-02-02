# Exotic Species Detection Service (ESDS)


## Overview

Application for the detection of exotic (introduced) occurrences of organisms in biodiversity observation data. Biodiversity observations are georeferenced occurrences of an organism at specific place and time. 

Species occurrence status is determined with reference to taxonomic checklists for political divisions (countries, states, counties) or other administrative regions, such as national parks and other protected areas.

## Application directory structure

```
|__admin/  Admin documents and applications
|__config/ Sensitive configuration parameters kept outside the main (public)
|          application code directory.
|__data/   Root data directory. Contains separate directories for user data amd  
           application database raw data.
|__src/    Main application code directory (this repository). 
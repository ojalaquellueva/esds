# Exotic Species Detection Service (ESDS)

Application for the detection of exotic (introduced) occurrences of organisms in biodiversity occurrence data. Biodiversity observations are georeferenced observations of an organism at specific place and (usually) time. 

Species occurrence status is determined with reference to taxonomic checklists for political divisions (countries, states, counties) or other administrative regions, such as national parks and other protected areas.

This is the application base directory. The main subdirectories are as follows:

```
|__admin/  Admin documents and applications
|__config/ Sensitive configuration parameters kept outside the main (public)
|          application code directory.
|__data/   Root data directory. Contains separate directories for user data amd  
           application database raw data.
|__src/    Main application code directory (this repository). 
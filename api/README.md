# Exotic Species Detection Service (ESDS) API

## Contents

[Introduction](#introduction)  
[Dependencies](#dependencies)  
[Required OS and software](#software)  
[Setup & configuration](#setup)  
[Usage](#usage)  
[Example scripts](#examples)  
[Centroid types](#centroid-types)  
[Centroid thresholds](#thresholds)  
[Raw input](#input)  
[Output & definitions](#output)  

<a name="introduction"></a>
## Introduction

The ESDS API is an API wrapper for esds.sh, the main script of the Exotic Species Detection Service (ESDS). 

<a name="software"></a>
## Required OS and software*
 *May work on earlier versions but not tested

* Ubuntu 20.04.2 LTS 
* Perl 5.26.1
* PHP 7.2.19
* PostgreSQL 10.14
* PostGIS 2.5.5
* Apache 2.4.29
* Makeflow 4.0.0 (released 02/06/2018)

PHP extensions:
  * php-cli
  * php-mbstring
  * php-curl
  * php-xml
  * php-json
  * php-services-json

<a name="usage"></a>
## Usage

#### Input data


#### Options


<a name="examples"></a>
## Example scripts

#### PHP

Example syntax for interacting with API using php\_curl is given in `esds_api_example.php`. To run the test script:

```
php esds_api_example.php
```
* Set parameters directly in script; no command line parameters
* Also see API parameters section at start of `esds_api_example.php `
* For ESDS options and defaults, see `params.php`
* Make sure that input file (`esds_testfile.csv`) is available in `$DATADIR` (as set in `params.php`)

#### R

* See example script `esds_api_example.R`. 
* Make sure that input file (`esds_testfile.csv`) is available in the same directory as the R script, or adjust file path in the R code.

<a name="input"></a>
## Raw input example



<a name="output"></a>
## Output & definitions

Below is a list of fields returned by the API and their definitions. GADM: Global administrative Divisions )https://gadm.org/).

| Field  | Definition | Units (if applicable)
| ------ | ---- | ----------

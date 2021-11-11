library(sf)
library(terra)
library(here)
library(tidyverse)

#### Get data dir ####
# The root of the data directory
data_dir = readLines(here("data_dir.txt"), n=1)

#### Convenience functions and main functions ####

source(here("scripts/convenience_functions.R"))


#### Processing ####

## Project area boundary
mask = st_read(datadir("focal-area/enf-and-ltbmu-buffered4km.gpkg"))

## Get all rasters needing cropping
files = list.files(datadir("veg-layers/01_downloaded-or-provided/"),recursive = TRUE, pattern = ".tif$")

## For each one:
for(file in files) {

  # Load
  r = rast(datadir(paste0("veg-layers/01_downloaded-or-provided/",file)))
  
  # Crop/mask
  r = crop(r,mask %>% st_transform(crs(r)))
  r = mask(r,mask %>% st_transform(crs(r)) %>% vect)
  
  # Make a nice file name that combines the dataset, year, and metric (obtained from the file path -- NOTE this requires consistently using the file path structure dataset/year/metric.tif in veg-layers/01_downloaded-or-provided)
  newfile = file %>% str_replace_all("/", "_")
  
  # Write
  writeRaster(r,datadir(paste0("veg-layers/02_cropped-to-enf-and-ltbmu/",newfile)),overwrite=TRUE)
    
}


### Do the same for the Riley data (which is in a different folder due to the need to preprocess it)

## Get all rasters needing cropping
files = list.files(datadir("veg-layers/00_riley/02_prepped-structure-layers"),recursive = TRUE, pattern = ".tif$")

## For each one:
for(file in files) {
  
  # Load
  r = rast(datadir(paste0("veg-layers/00_riley/02_prepped-structure-layers/",file)))
  
  # Crop/mask
  r = crop(r,mask %>% st_transform(crs(r)))
  r = mask(r,mask %>% st_transform(crs(r)) %>% vect)
  
  # Make a nice file name that combines the dataset, year, and metric (obtained from the file path -- NOTE this requires consistently using the file path structure dataset/year/metric.tif in veg-layers/01_downloaded-or-provided)
  newfile = file %>% str_replace_all("/", "_")
  
  # Write
  writeRaster(r,datadir(paste0("veg-layers/02_cropped-to-enf-and-ltbmu/riley_",newfile)),overwrite=TRUE)
  
}

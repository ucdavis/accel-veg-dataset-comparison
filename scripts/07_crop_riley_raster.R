library(sf)
library(terra)
library(here)
library(tidyverse)

#### Get data dir ####
# The root of the data directory
data_dir = readLines(here("data_dir.txt"), n=1)

#### Convenience functions  ####
source(here("scripts/convenience_functions.R"))

#### Processing ####

# Load the Riley raster that contains the indexes that link to FIA plots
r = rast(datadir("veg-layers/00_riley/provided/national_c2014_tree_list.tif"))

# Load mask
mask = st_read(datadir("focal-area/enf-and-ltbmu-buffered4km.gpkg"))

# Crop raster
r_crop = crop(r,mask %>% st_transform(crs(r)))
r_mask = mask(r_crop,mask %>% st_transform(crs(r)) %>% vect)

# Write
writeRaster(r_mask,datadir("veg-layers/00_riley/01_index-raster-cropped/riley-plotraster-cropped.tif"))



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

## Load plot data, make spatial
d = read_csv(datadir("validation-data/validation-plots-dummy.csv"))
d_sf = st_as_sf(d,coords=c("lon","lat"))
st_crs(d_sf) = 4326 # lat/long WGS84 geographic


### For each veg metric raster: load, extract metric values at plot locations

rasters = list.files(datadir("veg-layers/02_cropped-to-enf-and-ltbmu"), pattern = ".tif$")

for(raster in rasters) {

  r = rast(datadir(paste0("veg-layers/02_cropped-to-enf-and-ltbmu/",raster)))
  
  # Set the column name following the naming convention "dataset_year_metric"
  name = str_remove(raster,".tif")
  names(r) = name
  
  # Extract
  extracted = terra::extract(r,d_sf %>% st_transform(crs(r)) %>% vect, method="bilinear")
  
  # Add to data frame
  d_sf[,name] = extracted[name]
  
}

# Convert to non-spatial and write
d_df = d_sf
st_geometry(d_df) = NULL

write_csv(d_df, datadir("veg-metrics-extracted/veg-layer-data-extracted.csv"))

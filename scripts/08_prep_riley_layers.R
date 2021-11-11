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

## Read the (cropped) Riley raster that contains the indexes that link to FIA plots
r = rast(datadir("veg-layers/00_riley/cropped/riley-plotraster-cropped.tif"))

## Get a list of all the indexes that link to FIA plots
indexes = unique(values(r))

## Load the FIA tree data
trees = read_csv(datadir("veg-layers/00_riley/provided/Tree_table_CONUS.txt"))
# keep only the rows with plot IDs that occur in our focal region
trees = trees %>%
  filter(tl_id %in% indexes) %>%
  #also don't keep any trees with no DBH (NOTE: need to check that this makes sense for TPH calculations. Why is DBH missing for some trees? Should these trees be counted in TPH etc?)
  filter(!is.na(DIA))
  

### Compute structure metrics from the tree data
## NOTE: Need to check whether this tree list includes trees in the annular plot (and if so what the annular plot DBH cutoff is for each plot). Ideally I think we would exclude annular plot trees and only keep trees from the regular plot (subplots) (where all trees were sampled regardless of DBH)
## NOTE: Need to double check my math here
## NOTE: Might need to filter out some tree status codes

plot_structure = trees %>%
  group_by(tl_id) %>%
  summarize(tph = n()/0.0673, # I calculated that total FIA subplot area is 0.0673 ha
            ba_m2ph = sum(3.14*(DIA/100/2)^2)/0.0673) # Compute the basal area of each tree, sum, and expand to 1 ha. /100 to convert cm to m. Then /2 to convert diam to radius. 

### Create a raster for each of these structure metrics

# Get the indexes
indexes = values(r,mat=FALSE)

# Get the plot for each index
index_structure = plot_structure[match(indexes, plot_structure$tl_id),]

# TPH raster
tph = r
values(tph) = index_structure$tph
writeRaster(tph,datadir("veg-layers/00_riley/02_prepped-structure-layers/2014/tph.tif"))

# BA raster
ba_m2ph = r
values(ba_m2ph) = index_structure$ba_m2ph
writeRaster(ba_m2ph,datadir("veg-layers/00_riley/02_prepped-structure-layers/2014/ba-m2ph.tif"))

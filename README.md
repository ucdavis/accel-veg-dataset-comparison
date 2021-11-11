# ACCEL vegetation dataset comparison

Evaluating alternative raster-based forest vegetation datasets against field validation plots. The data carpentry and analysis scripts are located in this repository. The data files (raw and processed) are kept outside the repository (due to their large size) on Box in [accel-veg-dataset-comparison_data] (https://ucdavis.box.com/s/59brlcvqmj93g4yw8igonn5pyr5stn8i). The data directory holds both raw (unprocessed input), intermediate, and final files. Therefore, it is not necessary to re-generate the intermediate files every time you want to do an analysis on them (for example).

### Linking to the data directory

To access the data directory from the scripts, sync it to your computer. Then set the repo data directory path by editing the file `data_dir.txt` (in the root level of the code repo). The code in the header of every script defines a function `datadir` that allows you to reference files within the data directory (regardless of where the data directory is located on your computer). For these header lines to work, you just need to make sure your working directory is set to the root level of the repo (which it should be by default if you use the RStudio project). So for example, to load the raster file at `accel-veg-dataset-comparison_data/veg-layers/01_downloaded-or-provided/gnn/2017/ba-m2ph.tif` (regardless of where the data directory is located on your computer), use the code `rast(datadir("veg-layers/01_downloaded-or-provided/gnn/2017/ba-m2ph.tif"))`. This technique can also be used for writing files. 


### Workflow

#### Data carpentry

1. Define the study area. Currently this is defined as the ENF + LTBMU (buffered by 4 km to remove holes) per discussions with project leadership. The study area is defined by the polygon stored in `{data_dir}/focal-area/enf-and-ltbmu-buffered4km.gpkg`.

1. Crop the Riley "tree list" raster. The central component of the Riley dataset is a "tree list" raster where the cell values are index values that link to FIA plots (the plot that Riley determined most closely matches the conditions in each cell). "Tree list" is kind of a misnomer because it's more like a plot list. This starts as a national raster. Crop it to the project area. Performed by `07_crop_riley_raster.R`.

1. Generate forest vegetation metric layers from the Riley data. Because the Riley raster simply links to FIA plots using index values for each grid cell, you need to compute forest vegetation (e.g., structure such as BA, TPH) metrics from the FIA tree inventory data and then assign these vegetation metric values to the raster cells to which they correspond. This saves the resulting layers (pre-cropped to the focal area) in the "raster prepared for analysis" folder at `{data_dir}/02_cropped-to-enf-and-ltbmu`, with file names following the format `{dataset}_{year}_{metric}.tif`. Performed by `08_prep_riley_layers.R`.

1. Crop the raw unprocessed vegetation dataset layers (non-Riley) to the project area. Save the resulting layers (pre-cropped to the focal area) in the "raster prepared for analysis" folder at `{data_dir}/02_cropped-to-enf-and-ltbmu`, with file names following the format `{dataset}_{year}_{metric}.tif`. This script relies on raw layer files being organized in `{data_dir}/veg-layers/01_downloaded-or-provided/` with the folder structure `{dataset}/{year}/{metric}.tif`. Performed by `10_crop-rasters-fo-focal-region.R`.


### Data storage structure

The following folders/files are located within the data directory.

* Study area polygons: `focal-area/`
* Raw Riley data (provided by Nick): `veg-layers/00_riley/01_downloaded-or-provided/`
* Cropped Riley "tree list" raster: `veg-layers/00_riley/02_cropped-to-enf-and-ltbmu/`
* Raw (non-Riley) vegetation data layers (provided by Nick or downloaded by Derek): `veg-layers/01_downloaded-or-provided/`. Beneath this folder, data layers are organized by dataset, year, and metric with a folder structure as follows: `{dataset}/{year}/{metric}.tif`.
* Veg layers cropped to the focal area, with standardized file names, ready for extraction/analysis: `veg-layers/02_cropped-to-enf-and-ltbmu/`. Beneath this folder, data layers are named by dataset, year, and metric as follows: `{dataset}_{year}_{metric}.tif`.
* Ancillary data, such as GNN readme and accuracy assessment that comes with the download: `veg-layers/99_ancillary-data/`.


### Notes and to-dos
* You can get GNN data from years other than 2017 by contacting Lemma (via the new download page on the website).
* The Lemma basal area values seem far too large to be in units of m^2/ha (as specified in the documentation).

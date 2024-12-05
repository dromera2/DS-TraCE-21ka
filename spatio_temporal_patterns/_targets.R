# Load packages required to define the pipeline:
library(targets)

source("packages.R")
source("functions.R")
source("arguments.R")

# Set target options:
tar_option_set(
  packages = c("dplyr", "stars", "dsclimtools", "raster", "patchwork", "ggplot2", "sf", "terra")
  )

list(
  tar_target(tas_ds_14650_14400, read_dsclim("../../Public/Data/dsclim_v1/netcdf/", "tas", -14650, -14400, proxy = TRUE)),
  tar_target(t_14650_14400, st_get_dimension_values(tas_ds_14650_14400, "time") %>% as.numeric(.)/(365*24*60*60)),
  tar_target(mad_14650_14400, stars::st_apply(tas_ds_14650_14400, MARGIN = c(1, 2), FUN=mad)),
  tar_target(write_mad_14650_14400, write_stars(mad_14650_14400, "mad_-14650_-14400.tif", chunk_size = c(50, 50))),
  tar_target(slope_14650_14400, stars::st_apply(tas_ds_14650_14400, MARGIN = c(1, 2), FUN = slope, t = t_14650_14400)),
  tar_target(write_slope_14650_14400, write_stars(slope_14650_14400, "slope_-14650_-14400.tif", chunk_size = c(50, 50))),
  #######
  tar_target(tas_ds_18149_17150, read_dsclim("../../Public/Data/dsclim_v1/netcdf/", "tas", -18149, -17150, proxy = TRUE)),
  tar_target(t_18149_17150, st_get_dimension_values(tas_ds_18149_17150, "time") %>% as.numeric(.)/(365*24*60*60)),
  tar_target(mad_18149_17150, stars::st_apply(tas_ds_18149_17150, MARGIN = c(1, 2), FUN=mad)),
  tar_target(write_mad_18149_17150, write_stars(mad_18149_17150, "mad_-18149_-17150.tif", chunk_size = c(50, 50))),
  tar_target(slope_18149_17150, stars::st_apply(tas_ds_18149_17150, MARGIN = c(1, 2), FUN = slope, t = t_18149_17150)),
  tar_target(write_slope_18149_17150, write_stars(slope_18149_17150, "slope_-18149_-17150.tif", chunk_size = c(50, 50))),
  #######
  tar_target(tas_ds_22000_40, read_dsclim("../../Public/Data/dsclim_v1/netcdf/", "tas", -22000, 40, proxy = TRUE)),
  tar_target(t_22000_40, st_get_dimension_values(tas_ds_22000_40, "time") %>% as.numeric(.)/(365*24*60*60)),
  tar_target(mad_22000_40, stars::st_apply(tas_ds_22000_40, MARGIN = c(1, 2), FUN=mad)),
  tar_target(write_mad_22000_40, write_stars(mad_22000_40, "mad_-22000_40.tif", chunk_size = c(50, 50))),
  tar_target(slope_22000_40, stars::st_apply(tas_ds_22000_40, MARGIN = c(1, 2), FUN = slope, t = t_22000_40)),
  tar_target(write_slope_22000_40, write_stars(slope_22000_40, "slope_-22000_40.tif", chunk_size = c(50, 50))),
  tar_target(combined_plot, composite.plot(mask)
             # , pattern = map(c(write_mad_14650_14400, write_slope_14650_14400,
             #                                                    write_mad_18149_17150, write_slope_18149_17150,
             #                                                    write_mad_22000_40, write_slope_22000_40))
             )
)












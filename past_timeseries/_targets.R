# Load packages required to define the pipeline:
library(targets)

source("packages.R")
source("arguments.R")
source("functions.R")

tar_option_set(packages = c("stars", "dsclimtools", "tidyverse", "ggplot2", "lubridate", "patchwork"))
list(
  tar_target(ds_tas, read_dsclim("../../Public/Data/dsclim_v1/netcdf/", "tas", start, end,
                                  calendar_dates = TRUE, sf = points, proxy = FALSE) %>%
               aggregate(by = agg.dates, FUN = mean, na.rm = TRUE)),
  tar_target(ds_pr, read_dsclim("../../Public/Data/dsclim_v1/netcdf/", "pr", start, end,
                                  calendar_dates = TRUE, sf = points, proxy = FALSE) %>%
               aggregate(by = agg.dates, FUN = mean, na.rm = TRUE)),
  tar_target(tas_trace, read_trace("../../Public/Data/TraCE21ka/", "TS", st_set_crs(points[1,], 4326))  %>%
               aggregate(by = agg.dates, FUN = mean, na.rm = TRUE)),
  tar_target(pr_trace, read_trace("../../Public/Data/TraCE21ka", "PRECC", st_set_crs(points[1,], 4326)) %>%
               aggregate(by = agg.dates, FUN = mean, na.rm = TRUE)),
  tar_target(chelsa_tmax_pixel1, read_stars(chelsa_tmax_files, along = "time") %>%
               st_set_dimensions(which = "time", values = chelsa_dates) %>%
               aggregate(by = pixel1, FUN = mean)),
  tar_target(chelsa_tmax_pixel1_C, ((chelsa_tmax_pixel1 * 0.1) - 273)),
  tar_target(chelsa_tmin_pixel1, read_stars(chelsa_tmin_files, along = "time") %>%
               st_set_dimensions(which = "time", values = chelsa_dates) %>%
               aggregate(by = pixel1, FUN = mean)),
  tar_target(chelsa_tmin_pixel1_C, ((chelsa_tmin_pixel1 * 0.1) - 273)),
  tar_target(chelsa_tmax_pixel2, read_stars(chelsa_tmax_files, along = "time") %>%
               st_set_dimensions(which = "time", values = chelsa_dates) %>%
               aggregate(by = pixel2, FUN = mean)),
  tar_target(chelsa_tmax_pixel2_C, ((chelsa_tmax_pixel2 * 0.1) - 273)),
  tar_target(chelsa_tmin_pixel2, read_stars(chelsa_tmin_files, along = "time") %>%
               st_set_dimensions(which = "time", values = chelsa_dates) %>%
               aggregate(by = pixel2, FUN = mean)),
  tar_target(chelsa_tmin_pixel2_C, ((chelsa_tmin_pixel2 * 0.1) - 273)),
  tar_target(chelsa_tas_1, ((chelsa_tmax_pixel1_C + chelsa_tmin_pixel1_C) / 2) %>%
               aggregate(calendar_dates(-22050, 40, by = "100 years"), FUN=mean, na.rm=TRUE)),
  tar_target(chelsa_tas_2, ((chelsa_tmax_pixel2_C + chelsa_tmin_pixel2_C) / 2) %>%
               aggregate(calendar_dates(-22050, 40, by = "100 years"), FUN=mean, na.rm=TRUE)),
  tar_target(chelsa_pr_1, read_stars(chelsa_pr_files, along = "time") %>%
               st_set_dimensions(which = "time", values = chelsa_dates) %>%
               aggregate(by = pixel1, FUN = mean) %>%
               aggregate(calendar_dates(-22050, 40, by = "100 years"), FUN=mean, na.rm=TRUE)),
  tar_target(chelsa_pr_2, read_stars(chelsa_pr_files, along = "time") %>%
               st_set_dimensions(which = "time", values = chelsa_dates) %>%
               aggregate(by = pixel2, FUN = mean) %>%
               aggregate(calendar_dates(-22050, 40, by = "100 years"), FUN=mean, na.rm=TRUE)),
  tar_target(tas_plot, plot.tas(periods, ds_tas, tas_trace, chelsa_tas_1, chelsa_tas_2)),
  tar_target(pr_plot, plot.pr(periods, ds_pr, pr_trace, chelsa_pr_1, chelsa_pr_2)),
  tar_target(full_plot, plot.join(tas_plot, pr_plot)),
  tar_target(uerra1_tas, get_uerra_data("../../Public/Data/UERRA/UERRA-HARMONIE/2m_temperature/latlon/1961-90_2m_temperature.nc",
                                        "tas", points[1,])),
  tar_target(uerra2_tas, get_uerra_data("../../Public/Data/UERRA/UERRA-HARMONIE/2m_temperature/latlon/1961-90_2m_temperature.nc",
                                        "tas", points[2,])),
  tar_target(present_chelsa1_tas, get_present_chelsa_point_tas(paste0("../../Public/Data/chelsa/v1.2/tmax/CHELSA_tmax10_",
                                                                sprintf("%02d", 1:12), "_1979-2013_V1.2_land.tif"),
                                                                paste0("../../Public/Data/chelsa/v1.2/tmin/CHELSA_tmin10_",
                                                                       sprintf("%02d", 1:12), "_1979-2013_V1.2_land.tif"), pixel1)),
  tar_target(present_chelsa2_tas, get_present_chelsa_point_tas(paste0("../../Public/Data/chelsa/v1.2/tmax/CHELSA_tmax10_",
                                                                       sprintf("%02d", 1:12), "_1979-2013_V1.2_land.tif"),
                                                                paste0("../../Public/Data/chelsa/v1.2/tmin/CHELSA_tmin10_",
                                                                       sprintf("%02d", 1:12), "_1979-2013_V1.2_land.tif"), pixel2)),
  tar_target(uerra1_pr, get_uerra_data("../../Public/Data/UERRA/MESCAN-SURFEX/total_precipitation/latlon/1961-90_total_precipitation.nc",
                                        "pr", points[1,], pixel1)),
  tar_target(uerra2_pr, get_uerra_data("../../Public/Data/UERRA/MESCAN-SURFEX/total_precipitation/latlon/1961-90_total_precipitation.nc",
                                       "pr", points[2,], pixel2)),
  tar_target(present_chelsa1_pr, get_present_chelsa_point_pr(paste0("../../Public/Data/chelsa/v1.2/prec/CHELSA_prec_",
                                                                    sprintf("%02d", 1:12), "_V1.2_land.tif"), pixel1)),
  tar_target(present_chelsa2_pr, get_present_chelsa_point_pr(paste0("../../Public/Data/chelsa/v1.2/prec/CHELSA_prec_",
                                                                    sprintf("%02d", 1:12), "_V1.2_land.tif"), pixel2)),
  tar_target(complete_plot, arrows.plot(tas_plot, uerra1_tas, uerra2_tas, present_chelsa1_tas, present_chelsa2_tas,
                                     pr_plot, uerra1_pr, uerra2_pr, present_chelsa1_pr, present_chelsa2_pr))
  )









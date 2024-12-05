# Load packages required to define the pipeline:
library(targets)

source("packages.R")
source("functions.R")
source("arguments.R")

# Set target options:
tar_option_set(
  packages = c("dsclimtools", "stars", "terra", "raster", "tidyverse",
               "lubridate", "dismo", "ggplot2", "gganimate", "KnowBR"))

list(
  tar_target(present_tmax, dsclimtools::read_dsclim("../../Public/Data/dsclim_v1/netcdf/", 
                                                    "tasmax",
                                                    present_start, 
                                                    present_end, 
                                                    calendar_dates = TRUE, 
                                                    proxy = FALSE)),
  tar_target(present_tmin, dsclimtools::read_dsclim("../../Public/Data/dsclim_v1/netcdf/",
                                                    "tasmin",
                                                    present_start, 
                                                    present_end, 
                                                    calendar_dates = TRUE, 
                                                    proxy = FALSE)),
  tar_target(present_prec, dsclimtools::read_dsclim("../../Public/Data/dsclim_v1/netcdf/", 
                                                    "pr",
                                                    present_start, 
                                                    present_end, 
                                                    calendar_dates = TRUE, 
                                                    proxy = FALSE)),
  tar_target(present_tmax2, lapply(seq(1, 360, by = 12), 
                                   FUN = stars_to_stack, 
                                   present_tmax)),
  tar_target(present_tmin2, lapply(seq(1, 360, by = 12), 
                                   FUN = stars_to_stack, 
                                   present_tmin)),
  tar_target(present_prec2, lapply(seq(1, 360, by = 12),
                                   FUN = stars_to_stack, 
                                   present_prec)),
  tar_target(past_tmax, dsclimtools::read_dsclim( "../../Public/Data/dsclim_v1/netcdf/", 
                                                  "tasmax",
                                                  past_start, 
                                                  past_end, 
                                                  calendar_dates = TRUE,
                                                  proxy = FALSE)),
  tar_target(past_tmin, dsclimtools::read_dsclim( "../../Public/Data/dsclim_v1/netcdf/", 
                                                  "tasmin",
                                                  past_start, 
                                                  past_end, 
                                                  calendar_dates = TRUE,
                                                  proxy = FALSE)),
  tar_target(past_prec, dsclimtools::read_dsclim( "../../Public/Data/dsclim_v1/netcdf/",
                                                  "pr",
                                                  past_start, 
                                                  past_end, 
                                                  calendar_dates = TRUE,
                                                  proxy = FALSE)),
  tar_target(past_tmax2, lapply(seq(1, 1212, by = 12), 
                                FUN = stars_to_stack, 
                                past_tmax)),
  tar_target(past_tmin2, lapply(seq(1, 1212, by = 12), 
                                FUN = stars_to_stack, 
                                past_tmin)),
  tar_target(past_prec2,  lapply(seq(1, 1212, by = 12),
                                 FUN = stars_to_stack, 
                                 past_prec)),
  tar_target(present_bio_list, mapply(dismo::biovars, 
                                      present_prec2, 
                                      present_tmin2, 
                                      present_tmax2,
                                      SIMPLIFY = FALSE)),
  tar_target(Present_bioclim, stack(reduce(present_bio_list, `+`) / length(present_bio_list)) %>% 
               subset(c(1, 5, 6, 7, 8, 12, 16, 17))),
  tar_target(past_bio_list, mapply(dismo::biovars, 
                                   past_prec2, 
                                   past_tmin2, 
                                   past_tmax2, 
                                   SIMPLIFY = FALSE) %>% 
               lapply(function(x){
                 subset(x, c(1, 5, 6, 7, 8, 12, 16, 17))
               })),
  tar_target(presvals, terra::extract(Present_bioclim, 
                                      presences, 
                                      na.rm = TRUE) %>% 
               as.data.frame() %>%
               drop_na()),
  tar_target(absvals, raster::extract(Present_bioclim, 
                                      absences, 
                                      na.rm = TRUE) %>% 
               as.data.frame() %>% 
               drop_na()),
  tar_target(pb, c(rep(1, nrow(presvals)), 
                     rep(0, nrow(absvals)))),
  tar_target(sdmdata, data.frame(cbind(pb, 
                                       rbind(presvals, absvals)))),
  tar_target(model,  glm(pb ~ bio1 + bio5 + bio6 + bio7 + bio8 + bio12 + bio16 + bio17, 
                         data = sdmdata, 
                         family = "binomial")),
  tar_target(present_prediction, Present_bioclim %>% 
               raster::mask(topo14_mask) %>% 
               predict(model, type = "response") %>% 
               as.data.frame(xy = TRUE) %>% na.omit()),
  tar_target(cont_present_plot, continuous.present.plot(present_prediction)),
  tar_target(bin_present_plot, binary.present.plot(present_prediction)),
  tar_target(past_prediction, past.pred(past_bio_list, topo14_mask, model)),
  tar_target(past_gift, gift.plot(past_prediction)),
  # tar_target(bin_past_plot, past.bin.plot, (past_prediction)),
  tar_target(past_subset_plot, subset.plot(past_prediction))
)











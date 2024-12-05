# Load packages required to define the pipeline:
library(targets)

source("packages.R")
source("arguments.R")
source("functions.R")

tar_option_set(packages = c("stars", "dsclimtools", "tidyverse", "ggplot2", "units"))
list(
  tar_target(past1, read_dsclim("../../Public/Data/dsclim_v1/netcdf/", "tas",
                                 10, 40, calendar_dates = TRUE, sf = point1, proxy = FALSE)),
  tar_target(past2, read_dsclim("../../Public/Data/dsclim_v1/netcdf/", "tas",
                                 10, 40, calendar_dates = TRUE, sf = point2, proxy = FALSE)),
  tar_target(fut1, mapply(get_dscmip_point_data, rcp = df$Var2, gcm = df$Var1, 
                          MoreArgs = list(folder = "../../Public/Data/dsclim_v1/netcdf/",
                                          var = "tas", start = 41, end = 150, sf = point1), SIMPLIFY = FALSE) %>% 
               bind_rows()),
  tar_target(fut1.agg, mapply(get_dscmip_point_data, rcp = df$Var2, gcm = df$Var1,
                              MoreArgs = list(folder = "../../Public/Data/dsclim_v1/netcdf/",
                                              var = "tas", start = 41, end = 150, sf = point1,
                                              agg = "1 year"), SIMPLIFY = FALSE) %>% 
               bind_rows()),
  tar_target(fut2, mapply(get_dscmip_point_data, rcp = df$Var2, gcm = df$Var1, 
                          MoreArgs = list(folder = "../../Public/Data/dsclim_v1/netcdf/",
                                          var = "tas", start = 41, end = 150, sf = point2), SIMPLIFY = FALSE) %>% 
               bind_rows()),
  tar_target(fut2.agg, mapply(get_dscmip_point_data, rcp = df$Var2, gcm = df$Var1,
                              MoreArgs = list(folder = "../../Public/Data/dsclim_v1/netcdf/",
                                              var = "tas", start = 41, end = 150, sf = point2,
                                              agg = "1 year"), SIMPLIFY = FALSE) %>% 
               bind_rows()),
  tar_target(fut_plot, plot.fut(past1, past2, fut1, fut1.agg, fut2, fut2.agg))
)


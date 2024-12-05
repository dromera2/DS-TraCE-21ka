start <- -22000
end <- 40 

agg.dates <- calendar_dates(start, end, by = "10 years")

points <- data.frame(id = c(1, 2), long = c(0, 0), lat = c(41.5, 42.8)) %>% 
  sf::st_as_sf(coords = c("long", "lat"))


pixel1 <- sf::st_read("../../Med-Refugia/10-Paper/02-Figure_timeseries_ds-chelsa/pixel1.gpkg")
pixel2 <- sf::st_read("../../Med-Refugia/10-Paper/02-Figure_timeseries_ds-chelsa/pixel2.gpkg")

df1 <- expand.grid(1:12, -200:20)

df2 <- expand.grid(1:12, seq(from= -20100, to=1900,  by= 100))
chelsa_dates <- lubridate::ymd(paste0("0000-", df2$Var1, "-01")) + lubridate::years(df2$Var2)

chelsa_tmax_files <- paste0("../../Med-Refugia/Data/chelsa_trace/tasmax/CHELSA_TraCE21k_tasmax_", df1$Var1, "_", df1$Var2, "_V1.0.tif")
chelsa_tmin_files <- paste0("../../Med-Refugia/Data/chelsa_trace/tasmin/CHELSA_TraCE21k_tasmin_", df1$Var1, "_", df1$Var2, "_V1.0.tif")
chelsa_pr_files <- paste0("../../Public/Data/Chelsa-Trace/envicloud/chelsa/chelsa_V1/chelsa_trace/pr/CHELSA_TraCE21k_pr_",
                          df1$Var1, "_", df1$Var2, "_V1.0.tif")

periods <- data.frame(date_start= c(ymd(paste0("0000-", 1,"-01")) + years(-12450), ymd(paste0("0000-", 1,"-01")) + years(-15200)) ,
                      date_end = c(ymd(paste0("0000-", 1,"-01")) + years(-12700),
                                   ymd(paste0("0000-", 1,"-01")) + years(-16200)))

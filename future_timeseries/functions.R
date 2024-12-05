get_dscmip_point_data <- function(folder, var, start, end, rcp, gcm, sf, agg = NULL){
  data <- dsclimtools::read_dsclim(folder, var, start, end, rcp, gcm, calendar_dates = TRUE, sf, proxy = FALSE)
  
  if(!is.null(agg)){
    data <- aggregate(data, by = calendar_dates(start, end, agg), FUN = mean, na.rm = TRUE)
  } 
  
  data <- as.data.frame(data)
  data$gcm <- gcm
  data$rcp <- rcp
  data
} 


plot.fut <- function(past1, past2, fut1, fut1.agg, fut2, fut2.agg) {
  future_plot <- ggplot() +
    
    ggplot2::geom_line(data = drop_units(as.data.frame(past1)), aes(x = time, y = tas), color = "#E69F00", alpha = 0.3) + 
    ggplot2::geom_line(data = drop_units(as.data.frame(aggregate(past1, by = calendar_dates(10, 41, "1 year"), FUN = mean, na.rm = TRUE))), aes(x = time, y = tas), color = "#E69F00") + 
    
    ggplot2::geom_line(data = drop_units(as.data.frame(past2)), aes(x = time, y = tas), color = "#56B4E9", alpha = 0.3) + 
    ggplot2::geom_line(data = drop_units(as.data.frame(aggregate(past2, by = calendar_dates(10, 41, "1 year"), FUN = mean, na.rm = TRUE))), aes(x = time, y = tas), color = "#56B4E9") + 
    stat_summary(data = drop_units(fut1), aes(x = time, y = tas, group = rcp, color = rcp), fun = mean, geom = 'line', alpha = 0.3) +
    stat_summary(data = drop_units(fut1.agg), aes(x = time, y = tas, group = rcp, color = rcp), fun = mean, geom = 'line') +
    
    stat_summary(data = drop_units(fut2), aes(x = time, y = tas, group = rcp, color = rcp), fun = mean, geom = 'line', alpha = 0.3) +
    stat_summary(data = drop_units(fut2.agg), aes(x = time, y = tas, group = rcp, color = rcp), fun = mean, geom = 'line') +
    ggplot2::theme_light() +
    ggplot2::labs(y = "Surface Temperature (ºC)", x = "Time (calendar years)") +
    ggplot2::coord_cartesian(xlim = as.Date(c('1980-01-01','2100-12-31'))) +
    
    ggplot2::scale_color_discrete(name = "Emission\npathways",
                                  guide = "legend")
  
  future_plot
  
  ggsave("./figures/future_plot.jpg", height = 5, width = 10)
  
  future_plot
}

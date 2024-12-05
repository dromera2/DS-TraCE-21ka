 
plot.tas <- function(periods, ds_tas, tas_trace, chelsa_tas_1, chelsa_tas_2) {
  tas_plot <- ggplot() +
    ggplot2::geom_rect(data = periods, aes(xmin = date_start, xmax = date_end, ymin = -Inf, ymax = Inf), fill = "grey", alpha= 0.7) +
    geom_line(data = as.data.frame(ds_tas), aes(x = time, y = tas, colour = st_as_text(geometry), linetype = "f1")) +
    geom_line(data = as.data.frame(tas_trace), aes(x = time, y = TS, colour = "#000000", linetype = "solid")) +
    geom_step(data = as.data.frame(chelsa_tas_1), aes(x = time, y = attr, colour = "POINT (0 41.5)", linetype = "11")) +
    geom_step(data = as.data.frame(chelsa_tas_2), aes(x = time, y = attr, colour = "POINT (0 42.8)", linetype = "11")) +
    theme_light() +
    theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
    labs(y = "Surface Temperature (ºC)", x = "Time (calendar years)") +
    coord_cartesian(xlim = c(lubridate::ymd("1950-01-01") + c(lubridate::years(-21150), lubridate::years(240)))) +
    
    scale_linetype_identity(name = "Data source",
                            breaks = c("solid", "f1", "11"),
                            labels = c("TraCE21ka", "dsclim", "Chelsa-TraCE"),
                            guide = "legend") +
    
    scale_color_manual(values=c("#000000", "#E69F00", "#56B4E9"),
                       labels = c("Trace pixel", "Point A", "Point B"),
                       guide = "legend",
                       name = "Location") 
  tas_plot
  
  ggsave("./figures/tas_plot.jpg", height = 5, width = 10)
  
  tas_plot
}


plot.pr <- function(periods, ds_pr, pr_trace, chelsa_pr_1, chelsa_pr_2) {
  pr_plot <- ggplot() +
    ggplot2::geom_rect(data = periods, aes(xmin = date_start, xmax = date_end, ymin = -Inf, ymax = Inf), fill = "grey", alpha= 0.7) +
    geom_line(data = as.data.frame(ds_pr), aes(x = time, y = pr, colour = st_as_text(geometry), linetype = "f1")) +
    geom_line(data = as.data.frame(pr_trace), aes(x = time, y = PRECC, colour = "#000000", linetype = "solid")) +
    geom_step(data = as.data.frame(chelsa_pr_1), aes(x = time, y = attr, colour = "POINT (0 41.5)", linetype = "11")) +
    geom_step(data = as.data.frame(chelsa_pr_2), aes(x = time, y = attr, colour = "POINT (0 42.8)", linetype = "11")) +  theme_light() +
    theme(axis.text.x=element_text(angle = 45, hjust = 1)) +
    labs(y = "Precipitation (mm)", x = "Time (calendar years)") +
    coord_cartesian(xlim = c(lubridate::ymd("1950-01-01") + c(lubridate::years(-21150), lubridate::years(240)))) +
    
    scale_linetype_identity(name = "Data source",
                            breaks = c("solid", "f1", "11"),
                            labels = c("TraCE21ka", "dsclim", "Chelsa-TraCE"),
                            guide = "legend") +
    
    scale_color_manual(values=c("#000000", "#E69F00", "#56B4E9"),
                       labels = c("Trace pixel", "Point A", "Point B"),
                       guide = "legend",
                       name = "Location") 
  
  
  pr_plot
  
  ggsave("./figures/pr_plot.jpg", height = 5, width = 10)
  
  pr_plot
}

plot.join <- function(tas_plot, pr_plot) {
  join_plot <- tas_plot + labs(y = "Surface Temperature (ºC)", x = "") + 
    theme(axis.text.x= element_blank()) + pr_plot + plot_layout(ncol = 1, guides = "collect")
  
  join_plot
  
  ggsave("./figures/join_plot.jpg", height = 5, width = 10)
  
  join_plot
}

get_uerra_data <- function(file, var, sf, pixel = NULL){
  
  if(var == "tas"){
    data <- read_stars(file)
    data <- time_2_calendar_dates(data, 11, 40)
    data <- st_crop(data, sf)
    data <- kelvin2celsius(data)
    uerra <- as.data.frame(data)
    uerra <- uerra[,4:5] 
    colnames(uerra) <- c("time", var)
    uerra_mean <- as.numeric(mean(uerra$tas))
  }else{
    data <- read_stars(file)
    st_crs(data) <- st_crs(pixel)
    data <- aggregate(data, pixel, mean)
    data <- time_2_calendar_dates(data, 11, 40)
    # data <- st_crop(data, sf)
    uerra <- as.data.frame(data)
    uerra <- uerra[,2:3] 
    colnames(uerra) <- c("time", var)
    uerra_mean <- as.numeric(mean(uerra$pr))
  }
  uerra_mean
} 


present.chelsa.format <- function(present_chelsa_tmean) {
  present_chelsa <- as.data.frame(present_chelsa_tmean)
  present_chelsa <- present_chelsa[1, 2:13]
  present_chelsa <- (sum(present_chelsa[1,] )/12)* 0.1
  present_chelsa
}


get_present_chelsa_point_tas <- function(filesmax, filesmin, pixel) {
  full_present_chelsa_tmax <- read_stars(filesmax)
  full_present_chelsa_tmin <- read_stars(filesmin)
  present_chelsa_tmax_point <- aggregate(full_present_chelsa_tmax, pixel, mean)
  present_chelsa_tmin_point <- aggregate(full_present_chelsa_tmin, pixel, mean)
  present_chelsa_tmean_point <- (present_chelsa_tmax_point + present_chelsa_tmin_point) / 2
  present_chelsa_plot <- present.chelsa.format(present_chelsa_tmean_point)
  present_chelsa_plot
}

get_present_chelsa_point_pr <- function(files, pixel) {
  full_present_chelsa_pr <- read_stars(files)
  present_chelsa_pr_point <- aggregate(full_present_chelsa_pr, pixel, mean)
  # present_chelsa_plot <- present.chelsa.format(present_chelsa_pr_point)
  
  present_chelsa_plot <- as.data.frame(present_chelsa_pr_point)
  present_chelsa_plot <- present_chelsa_plot[1, 2:13]
  present_chelsa_plot <- (sum(present_chelsa_plot[1,] )/12)
  present_chelsa_plot
}


arrows.plot <- function(tas_plot, uerra1_tas, uerra2_tas, present_chelsa1_tas, present_chelsa2_tas,
                        pr_plot, uerra1_pr, uerra2_pr, present_chelsa1_pr, present_chelsa2_pr) {
  tas_plot <- tas_plot +
    ggplot2::geom_segment(aes(x = dplyr::last(dsclimtools::calendar_dates(949, 949)),
                              y = uerra1_tas, xend = dplyr::last(dsclimtools::calendar_dates(41, 41)),
                              yend = uerra1_tas), color = "#E69F00", arrow = arrow(length = unit(0.03, "npc")),
                          lineend = "butt", linejoin = "round", linetype = "f1") +
    ggplot2::geom_segment(aes(x = dplyr::last(dsclimtools::calendar_dates(949, 949)),
                              y = uerra2_tas, xend = dplyr::last(dsclimtools::calendar_dates(41, 41)),
                              yend = uerra2_tas), color = "#56B4E9", arrow = arrow(length = unit(0.03, "npc")),
                          lineend = "butt", linejoin = "round", linetype = "f1") +
    ggplot2::geom_segment(aes(x = dplyr::last(dsclimtools::calendar_dates(749, 749)),
                              y = present_chelsa1_tas, xend = dplyr::last(dsclimtools::calendar_dates(40, 40)),
                              yend = present_chelsa1_tas), color = "#E69F00", arrow = arrow(length = unit(0.03, "npc")), 
                          lineend = "butt", linejoin = "round", linetype = "11") +
    ggplot2::geom_segment(aes(x = dplyr::last(dsclimtools::calendar_dates(749, 749)),
                              y = present_chelsa2_tas, xend = dplyr::last(dsclimtools::calendar_dates(40, 40)),
                              yend = present_chelsa2_tas), color = "#56B4E9", arrow = arrow(length = unit(0.03, "npc")), 
                          lineend = "butt", linejoin = "round", linetype = "11") 
  
  
  pr_plot <- pr_plot +
    ggplot2::geom_segment(aes(x = dplyr::last(dsclimtools::calendar_dates(949, 949)),
                              y = uerra1_pr, xend = dplyr::last(dsclimtools::calendar_dates(41, 41)),
                              yend = uerra1_pr), color = "#E69F00", arrow = arrow(length = unit(0.03, "npc")),
                          lineend = "butt", linejoin = "round", linetype = "f1") +
    ggplot2::geom_segment(aes(x = dplyr::last(dsclimtools::calendar_dates(949, 949)),
                              y = uerra2_pr, xend = dplyr::last(dsclimtools::calendar_dates(41, 41)),
                              yend = uerra2_pr), color = "#56B4E9", arrow = arrow(length = unit(0.03, "npc")),
                          lineend = "butt", linejoin = "round", linetype = "f1") +
    ggplot2::geom_segment(aes(x = dplyr::last(dsclimtools::calendar_dates(749, 749)),
                              y = present_chelsa1_pr, xend = dplyr::last(dsclimtools::calendar_dates(40, 40)),
                              yend = present_chelsa1_pr), color = "#E69F00", arrow = arrow(length = unit(0.03, "npc")), 
                          lineend = "butt", linejoin = "round", linetype = "11") +
    ggplot2::geom_segment(aes(x = dplyr::last(dsclimtools::calendar_dates(749, 749)),
                              y = present_chelsa2_pr, xend = dplyr::last(dsclimtools::calendar_dates(40, 40)),
                              yend = present_chelsa2_pr), color = "#56B4E9", arrow = arrow(length = unit(0.03, "npc")), 
                          lineend = "butt", linejoin = "round", linetype = "11") 
  
  
  join_plot <- tas_plot + labs(y = "Surface Temperature (ºC)", x = "") + 
    theme(axis.text.x= element_blank()) + pr_plot + plot_layout(ncol = 1, guides = "collect") 
  
  join_plot
  
  ggsave("./figures/join_plot_arrows.jpg", height = 5, width = 10)
  
  join_plot
}

slope = function(x, t) {
  if (anyNA(x)){
    NA_real_
  } else {
    lm.fit(cbind(1, t), x)$coefficients[2]
  } 
}


composite.plot <- function(mask) {
  mad_22000_40 <- (rast("./mad_-22000_40.tif")*mask) %>% as.data.frame(xy = TRUE) %>%
    mutate("period" = "-22000_40")
  colnames(mad_22000_40) <- c("x", "y", "MAD", "Period")
  
  mad_18149_17150 <- (rast("./mad_-18149_-17150.tif") * mask) %>% as.data.frame(xy = TRUE) %>%
    mutate("period" = "-18149_-17150")
  colnames(mad_18149_17150) <- c("x", "y", "MAD", "Period")
  
  mad_14650_14400 <- (rast("./mad_-14650_-14400.tif") * mask) %>% as.data.frame(xy = TRUE) %>%
    mutate("period" = "-14650_-14400")
  colnames(mad_14650_14400) <- c("x", "y", "MAD", "Period")
  
  mad <- bind_rows(mad_22000_40, mad_18149_17150, mad_14650_14400)
  
  mad_plot <- mad %>%
    ggplot() +
    geom_tile(aes(x = x, y = y, fill = MAD, col = MAD)) +
    coord_equal() +
    scale_fill_viridis_c() +
    scale_colour_viridis_c() +
    xlab("Longitude") +
    ylab("Latitude") +
    facet_grid(Period ~ .) +
    theme_bw() +
    theme(strip.background = element_blank(),
          strip.text.y = element_blank()) 
  
  
  slope_22000_40 <- (rast("./slope_-22000_40.tif") * mask * 10) %>% as.data.frame(xy = TRUE) %>%
    mutate("period" = "-22000_40")
  colnames(slope_22000_40) <- c("x", "y", "Slope", "Period")
  
  slope_18149_17150 <- (rast("./slope_-18149_-17150.tif") * mask) %>% as.data.frame(xy = TRUE) %>%
    mutate("period" = "-18149_-17150")
  colnames(slope_18149_17150) <- c("x", "y", "Slope", "Period")
  
  slope_14650_14400 <- (rast("./slope_-14650_-14400.tif") * mask) %>% as.data.frame(xy = TRUE) %>%
    mutate("period" = "-14650_-14400")
  colnames(slope_14650_14400) <- c("x", "y", "Slope", "Period")
  
  slope <- bind_rows(slope_22000_40, slope_18149_17150, slope_14650_14400)
  
  slope_plot <- slope %>%
    ggplot() +
    geom_tile(aes(x = x, y = y, fill = Slope, col = Slope)) +
    coord_equal() +
    scale_fill_gradientn(colours = c("blue", "lightblue", "lightyellow", "pink", "red"), 
                         limits = c(-0.015, 0.015), 
                         values = c(0, .45, .5, .55, 1)) +
    scale_colour_gradientn(colours = c("blue", "lightblue", "lightyellow", "pink", "red"), 
                           limits = c(-0.015, 0.015),
                           values = c(0, .45, .5, .55, 1)) +
    xlab("") +
    ylab("") +
    theme_bw() +
    theme(axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.x = element_blank(),
          axis.ticks.y = element_blank()) +
    facet_grid(Period ~ .) 
  
  
  wrap_plots(mad_plot, slope_plot, guides = "collect")
  
  ggsave("./mad_slope_composite.jpg", height = 6, width = 7)
}


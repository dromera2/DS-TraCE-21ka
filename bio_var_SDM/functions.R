stars_to_stack <- function(i, data){
  data %>% slice("time", i:(i+11)) %>% 
    rast() %>% stack()
}

model.projection <- function(p, predictors_list, land, model) {
  predictors <- predictors_list[[p]] %>% 
    raster::mask(land)
  prediction <- predict(predictors, 
                        model, 
                        type = "response")
  prediction
}

continuous.present.plot <- function(present_prediction){
  
  present_prediction %>% ggplot() +
    geom_raster(aes(x = x, 
                    y = y, 
                    fill = layer)) +
    scale_fill_viridis_c() +
    theme_bw() + 
    theme(axis.title.x = element_blank(), 
          axis.title.y = element_blank()) 
  
  ggsave("./figures/cont_present_pred.jpg", height = 5, width = 7.5)
}

binary.present.plot <- function(present_prediction){
  present_prediction %>% 
    mutate(th_layer = case_when(layer >= 0.7 ~ 1,
                                layer < 0.7 ~ 0)) %>% 
    ggplot() +
    geom_raster(aes(x = x, 
                    y = y, 
                    fill = th_layer)) +
    scale_fill_viridis_c() +
    theme_bw() + 
    theme(axis.title.x = element_blank(), 
          axis.title.y = element_blank()) 
  
  ggsave("./figures/bin_present_pred.jpg", height = 5, width = 7.5)
}



past.pred <- function(past_bio_list, topo14_mask, model) {
  past_prediction <- lapply(seq(1, 101), 
                            FUN = model.projection, 
                            past_bio_list, 
                            topo14_mask, 
                            model)
  
  names(past_prediction) <- paste0(-14500:-14400)
  
  past_prediction <- lapply(past_prediction, 
                            FUN = as.data.frame, 
                            xy = TRUE, 
                            na.rm = TRUE) %>% 
    reshape2::melt(id.vars = c("x", "y", "layer")) %>% 
    mutate(year = as.numeric(L1)) 
  
  past_prediction$L1 <- past_prediction$L1 %>% 
    as.numeric() %>% 
    as.factor()
  
  years_list <- seq(-14500, -14400, by = 1)
  
  levels(past_prediction$year) <- years_list %>% 
    lapply(FUN = last) %>%
    unlist()
  
  past_prediction$year <- past_prediction$year %>% 
    as.character() %>% 
    as.numeric()
  
  past_prediction
}



gift.plot <- function(past_prediction) {
  
  gg <- ggplot(
    past_prediction, 
    aes(x = x,
        y = y, 
        fill = layer)) +
    geom_raster() +
    scale_fill_viridis_c() +
    labs(title = "Year: {current_frame}") +
    theme_minimal() + 
    theme(axis.title.x = element_blank(), 
          axis.title.y = element_blank()) 
  
  options(gganimate.dev_args = list(width = 600, 
                                    height = 400))
  
  gganim <- gg + 
    transition_manual(year)
  
  animate(gganim, 
          duration = 60, 
          width = 600, 
          height = 400, 
          renderer = gifski_renderer())
  
  anim_save("timeseries_pred.gif", animation = last_animation(), path = "./figures/")
}



past.bin.plot <- function(past_prediction) {
  
  mean_data <- past_prediction %>% 
    group_by(x, y) %>% 
    summarize(mean_layer = mean(layer)) %>% 
    mutate(th_layer = case_when(mean_layer >= 0.7 ~ 1,
                                mean_layer < 0.7 ~ 0))
  
  mean_data %>% ggplot() +
    geom_raster(aes(x = x, 
                    y = y, 
                    fill = th_layer)) +
    scale_fill_viridis_c() +
    theme_bw() + 
    theme(axis.title.x = element_blank(), 
          axis.title.y = element_blank()) 
  
  ggsave("./figures/bin_past_pred.jpg", height = 5, width = 7.5)
}


subset.plot <- function(past_prediction) {
  subset_data <- past_prediction %>% filter(year %in% c(-14400, -14410, -14420, -14430,
                                                  -14440, -14450, -14460, -14470,
                                                  -14480, -14490))
  
  subset_data %>% ggplot() +
    geom_raster(aes(x = x, y = y, fill = layer)) +
    scale_fill_viridis_c(name = "value") +
    facet_wrap(.~year, ncol = 2) +
    coord_equal() +
    theme_bw() +
    xlab("Longitude") +
    ylab("Latitude") +
    theme(legend.title=element_blank())
  
  
  ggsave("./figures/glm_composite.jpg", height = 6, width = 6)
}


point1 <- data.frame(id = c(1), long = c(0), lat = c(41.5)) %>% 
  sf::st_as_sf(coords = c("long", "lat"))

point2 <- data.frame(id = c(1), long = c(0), lat = c(42.8)) %>% 
  sf::st_as_sf(coords = c("long", "lat"))


rcps <- c("rcp2.6", "rcp4.5", "rcp6.0", "rcp8.5")
gcms <- c("CESM1-CAM5", "CSIRO-Mk3-6-0", "IPSL-CM5A-MR")

df <- expand.grid(gcms, rcps)
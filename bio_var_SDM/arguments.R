
present_start <- 11
present_end <- 40

past_start <- -14500
past_end <- -14400

data("Beetles", package = "KnowBR")

presences <- Beetles %>%
  as.data.frame() %>%
  filter(Species == "Bubas bison") %>% 
  select(Longitude, Latitude)

topo14_mask <- system.file("extdata", 
                           "topo14_mask.tif", 
                           package = "dsclimtools") %>% 
  raster()

set.seed(1)
absences <- randomPoints(topo14_mask, 
                         400, 
                         presences)

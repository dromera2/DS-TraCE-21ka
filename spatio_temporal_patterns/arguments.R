# mask <- vect("./input/mask.shp")
# reference <- rast("./mad_-14650_-14400.tif")
# 
# test <- rasterize(mask, reference)
# 
# writeRaster(test, "./input/mask.tif", overwrite = TRUE)

mask <- rast("./input/mask.tif")

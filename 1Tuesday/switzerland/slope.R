library(unmarked)
data("Switzerland")
coords <- Switzerland[, c("x", "y", "elevation")]
library(sf)
library(terra)
site_coords <- st_as_sf(coords, coords = c("x", "y"), crs = "EPSG:21781")

# Step 2: Create a 1km x 1km grid
# Define the grid's extent and resolution
x_min <- min(coords$x)
x_max <- max(coords$x)
y_min <- min(coords$y)
y_max <- max(coords$y)

library(terra)
grid <- rast(ext = c(x_min, x_max, y_min, y_max), res = 1000)  # 1km resolution grid

# Step 3: Interpolate the elevation data onto the grid
# Inverse Distance Weighting (IDW) interpolation example
# Convert the site_sf to a raster and interpolate
elevation_raster <- rasterize(site_coords, grid, field = "elevation", fun = "mean")
crs(elevation_raster) <- crs(site_coords)
slope <- terrain(elevation_raster)
crs(slope) <- crs(site_coords)
aspect <- terrain(elevation_raster, v="aspect")
crs(aspect) <- crs(site_coords)


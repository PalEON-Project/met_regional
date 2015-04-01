# #############################################################
# Script to extract MsTMIP soils information for PalEON modeling sites
# Raw data downloaded from: https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1242
# Christy Rollinson, crollinson@gmail.com
# 1 April 2015
# #############################################################

# -----------------------------------------------------------
# Libraries used
# -----------------------------------------------------------
library(ncdf4)
library(raster)

dir.in <- "~/Desktop/MsTMIP Env Drivers/NACP_MSTMIP_UNIFIED_NA_SOIL_MA_1242/data"
dir.out <- "~/Desktop/phase1a_env_drivers/phase1a_env_drivers_v4/"
# -----------------------------------------------------------

# -----------------------------------------------------------
# Importing the raw data & extracting for sites
# -----------------------------------------------------------
# Loading in Nitrogen Deposition files
soil.files <- dir(dir.in)
soils <- stack(file.path(dir.in, soil.files))
names(soils) <- c("Dom_Component", "Max_Depth", "Sub_CEC", "Sub_Gravel", "Sub_OC", "Sub_pH", "Sub_BulkDens", "Sub_Sand", "Sub_Silt", "Top_CEC", "Top_Clay", "Top_Gravel", "Top_OC", "Top_pH", "Top_Bulk", "Top_Sand", "Top_Silt")

sites <- data.frame(c("PHA", "PHO", "PUN", "PBL", "PDL", "PMB"))
names(sites) <- "Site"
sites$Lat <- c(42.54, 45.25, 46.22, 46.28, 47.17, 43.83) 
sites$Lon <- c(-72.18, -68.73, -89.53, -94.58, -95.17, -82.83)
summary(sites)
coordinates(sites) <- c("Lon", "Lat")

# Graphing the plots in soils space to make sure things line up at least somewhat
plot(sites, pch=19)
plot(soils[[1]], add=T, legend=)
plot(sites, add=T, pch=19)


# Extracting N Deposition for the sites 
soils.sites <- data.frame(t(extract(soils, sites, method="simple")))
names(soils.sites) <- sites$Site


soils.sites["Latitude",] <- sites$Lat
soils.sites["Longitude",] <- sites$Lon
soils.sites


write.csv(soils.sites, "PalEON_phase1a_env_drivers_v4_soils.csv", row.names=T)
# -----------------------------------------------------------

# #############################################################
# Script to extract MsTMIP Nitrogen Deposition for PalEON sites
# Raw data downloaded from: http://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1220
# Christy Rollinson, crollinson@gmail.com
# 18 March 2015
# #############################################################

# -----------------------------------------------------------
# Libraries used
# -----------------------------------------------------------
library(ncdf4)
library(raster)

dir.in <- "~/Desktop/MsTMIP Env Drivers"
dir.out <- "~/Desktop/phase1a_env_drivers/phase1a_env_drivers_v3/site_nitrogen"
# -----------------------------------------------------------

# -----------------------------------------------------------
# Importing the raw data & extracting for sites
# -----------------------------------------------------------
# Loading in Nitrogen Deposition files
noy <- stack(file.path(dir.in, "mstmip_driver_na_qd_nitrogen_noy_v1.nc4"))
nhx <- stack(file.path(dir.in, "mstmip_driver_na_qd_nitrogen_nhx_v1.nc4"))
# noy # prints info about the n data
# nhx # prints info about the n data

sites <- data.frame(c("PHA", "PHO", "PUN", "PBL", "PDL", "PMB"))
names(sites) <- "Site"
sites$Lat <- c(42.5, 45.5, 46.5, 46.5, 47.5, 43.5) 
sites$Lon <- c(-72.5, -68.5, -89.5, -94.5, -95.5, -82.5)
summary(sites)
coordinates(sites) <- c("Lon", "Lat")

# # Graphing the plots on top of the N data to make sure things look like they line up in space
# plot(noy[[1]])
# plot(sites, add=T, pch=19)

# Extracting N Deposition for the sites 
noy.sites <- data.frame(t(extract(noy, sites, method="simple")))
nhx.sites <- data.frame(t(extract(nhx, sites, method="simple")))
names(noy.sites) <- names(nhx.sites) <- sites$Site
row.names(noy.sites) <- row.names(nhx.sites) <- years <- substr(row.names(noy.sites),2,5)
summary(noy.sites)
summary(nhx.sites)

# ---------------------
# Note: N deposition here goes from 1860 to 2050; we want 850-2010
#		1) get rid of post-2010 data
#		2) assume 1860 N dep for pre-1860 levels (not great, but it's what was done in the past)
# ---------------------
# making some new data frames with the proper dimensions
noy.sites2 <- nhx.sites2 <- data.frame(array(NA, dim=c(length(850:2010),length(sites$Site))))
names(noy.sites2) <- names(nhx.sites2) <- sites$Site
row.names(noy.sites2) <- row.names(nhx.sites2) <- 850:2010

# Everything pre-1860 is the same as 1860
noy.sites2[1:(1860-850),] <- noy.sites[1,]
nhx.sites2[1:(1860-850),] <- nhx.sites[1,]
summary(noy.sites2)
summary(nhx.sites2)

# Putting 1860-2010 where it belongs
noy.sites2[(1860-850+1):nrow(noy.sites2),] <- noy.sites[1:(nrow(noy.sites)-40),]
nhx.sites2[(1860-850+1):nrow(nhx.sites2),] <- nhx.sites[1:(nrow(nhx.sites)-40),]
summary(noy.sites2)
summary(nhx.sites2)
# ---------------------
# Ta da!  Now we just have to write it to a .nc file for distribution!
# -----------------------------------------------------------

# -----------------------------------------------------------
# Writing site .nc files
# -----------------------------------------------------------
site.df <- data.frame(sites)
site.df

for(s in sites$Site){
	# ---------------------
	# Setting up the dim & var defs
	# ---------------------
	dim.time <- ncdim_def(name="time", units="year", vals=850:2010, calendar="standard")	
	dim.lat <- ncdim_def(name="latitude", units="degrees_east", vals=site.df[site.df$Site==s,"Lat"])
	dim.lat <- ncdim_def(name="longitude", units="degrees_north", vals=site.df[site.df$Site==s,"Lon"])

	noy.dep <- ncvar_def("NOy", units="mg N m-2 yr-1", dim=list(dim.time), longname="NOy-N Deposition")
	nhx.dep <- ncvar_def("NHx", units="mg N m-2 yr-1", dim=list(dim.time), longname="NHx-N Deposition")
	# ---------------------

	# ---------------------
	# Writing the file
	# ---------------------
	nc.noy <- nc_create(file.path(dir.out, paste(s, "noy.nc", sep="_")), noy.dep)
	nc.nhx <- nc_create(file.path(dir.out, paste(s, "nhx.nc", sep="_")), nhx.dep)

	ncvar_put(nc.noy, noy.dep, noy.sites2[,s])
	ncvar_put(nc.nhx, nhx.dep, nhx.sites2[,s])

	nc_close(nc.noy); nc_close(nc.nhx)
	# ---------------------
}
# -----------------------------------------------------------

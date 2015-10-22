# -------------------------------------------------------------------------
# Aggregate sub-daily (6 hrly) data into daily means for those models that 
# need it (LPJ)
# Original: Christy Rollinson, crollinson@gmail.com, 21 Sept, 2015
#
# Note: This script will stick to writing to monthly files so that we have 
#       a consistent met driver format, but we'll distribute a helper script 
#       that will concatenate these files into a single .nc
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Set up libraries, file paths, useful variables, etc
# -------------------------------------------------------------------------
library(ncdf4)

basedir <- "/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2/"
outpath <- "/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2_daily/"

if(!dir.exists(outpath)) dir.create(outpath)

# vars  <- c("lwdown","precipf","psurf","qair","swdown","tair","wind")
dpm   <- c(31,28,31,30,31,30,31,31,30,31,30,31) #days per month
dpm.l <- c(31,29,31,30,31,30,31,31,30,31,30,31) #leap year days per month
mv    <- 1e30    # Missing value
fillv   <- 1e+30
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Loop through each variable to do aggregation
# -------------------------------------------------------------------------
  # Get a list of files (should be 1 file per month)
  files <- dir(file.path(basedir,"tair"), ".nc")

  if(!dir.exists(file.path(outpath, "tmin"))) dir.create(file.path(outpath, "tmin"))
  if(!dir.exists(file.path(outpath, "tmax"))) dir.create(file.path(outpath, "tmax"))
    
  for(f in 1:length(files)){
    #format time as days since 850-01-01 midnight
    tmp  <- strsplit(files[f],"_")
    year <- as.numeric(tmp[[1]][2])
    mon  <- as.numeric(substring(tmp[[1]][3],1,2))
    print(year)

    nc.file <- nc_open(paste(basedir,"tair","/",files[f],sep=""))
    data.df <- ncvar_get(nc.file, "tair")
    time.df <- ncvar_get(nc.file, "time" )    
    lat     <- ncvar_get(nc.file, "lat" )
    lon     <- ncvar_get(nc.file, "lon" )
    nc_close(nc.file)
    
    # convert decimal days to just day ID & setting up dim defs
    nc_time_units <- paste('days since 0850-01-01 00:00:00', sep='')
    days          <- trunc(time.df)
    nc.time       <- unique(days)
    dim.time      <- ncdim_def("time",nc_time_units,nc.time,unlim=TRUE)
    
    # Looping through days to find the mean
    # NOTE: na.rm=F so that if there's a problem with missing data, we'll find it
	dat.min <- array(dim=c(nrow(data.df), ncol(data.df), length(nc.time)))
	dat.max <- array(dim=c(nrow(data.df), ncol(data.df), length(nc.time)))
    for(d in 1:length(nc.time)){
    	dat.min[,,d] <- apply(data.df[,,which(days == nc.time[d])], 1:2, min, na.rm=F)
    	dat.max[,,d] <- apply(data.df[,,which(days == nc.time[d])], 1:2, max, na.rm=F)
    }
 
    # Print correct units 
    nc_variable_long_name_min='2 meter air temperature, daily min'
    nc_variable_long_name_max='2 meter air temperature, daily min'
    nc_variable_units='K'
    
    # Make a few dimensions we can use
    dimY <- ncdim_def( "lat", "longitude: degrees", lat )
    dimX <- ncdim_def( "lon", "latitude: degrees", lon )
     
    nc_var_min  <- ncvar_def("tmin",nc_variable_units,
                            list(dimX,dimY,dim.time), fillv, longname=nc_variable_long_name_min,prec="double")
    nc_var_max  <- ncvar_def("tmax",nc_variable_units,
                            list(dimX,dimY,dim.time), fillv, longname=nc_variable_long_name_max,prec="double")
    
    ofname_min  <- file.path(outpath,"tmin",paste0("tmin","_",sprintf('%04i',year),'_',
                   sprintf('%02i',mon),'.nc'))
    ofname_max  <- file.path(outpath,"tmax",paste0("tmax","_",sprintf('%04i',year),'_',
                   sprintf('%02i',mon),'.nc'))

    newfile_min <- nc_create( ofname_min, nc_var_min ) # Initialize file 
    newfile_max <- nc_create( ofname_max, nc_var_min ) # Initialize file 
    
    ncatt_put( newfile_min, nc_var_min, 'days since 850', nc.time)
    ncatt_put( newfile_min, 0, 'description',"PalEON formatted Phase 1 met driver")

    ncatt_put( newfile_max, nc_var_max, 'days since 850', nc.time)
    ncatt_put( newfile_max, 0, 'description',"PalEON formatted Phase 1 met driver")
 
    ncvar_put(newfile_min, nc_var_min, dat.min) # Write netCDF file
    ncvar_put(newfile_max, nc_var_max, dat.max) # Write netCDF file
    
    nc_close(newfile_min);  nc_close(newfile_max)

  } # close file loop
} # Close variable loop
# -------------------------------------------------------------------------



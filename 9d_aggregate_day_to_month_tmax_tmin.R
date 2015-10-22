# -------------------------------------------------------------------------
# Aggregate sub-daily (6 hrly) data into monthly means for those models that 
# need it (LPJ)
# Original: Christy Rollinson, crollinson@gmail.com, 21 Sept, 2015
#
# Note: This script will go ahead and make a single datafile since it's hard
#       to conceive someone would want a file with a single value in it
# -------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Set up libraries, file paths, useful variables, etc
# -------------------------------------------------------------------------
library(ncdf4)
library(abind)

basedir <- "/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2_daily/"
outpath <- "/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2_monthly/"

if(!dir.exists(outpath)) dir.create(outpath)

vars  <- c("tmax", "tmin")
dpm   <- c(31,28,31,30,31,30,31,31,30,31,30,31) #days per month
dpm.l <- c(31,29,31,30,31,30,31,31,30,31,30,31) #leap year days per month
mv    <- 1e30    # Missing value
fillv   <- 1e+30
# -------------------------------------------------------------------------


# -------------------------------------------------------------------------
# Loop through each variable to do aggregation
# -------------------------------------------------------------------------
for(v in 1:length(vars)){
  print(paste("--------------------", vars[v], "--------------------", sep=" "))
  # Get a list of files (should be 1 file per month)
  files <- dir(file.path(basedir,vars[v]), ".nc")

  # if(!dir.exists(file.path(outpath, vars[v]))) dir.create(file.path(outpath, vars[v]))
    
  for(f in 1:length(files)){
    #format time as days since 850-01-01 midnight
    tmp  <- strsplit(files[f],"_")
    year <- as.numeric(tmp[[1]][2])
    mon  <- as.numeric(substring(tmp[[1]][3],1,2))
    print(year)

    nc.file <- nc_open(paste(basedir,vars[v],"/",files[f],sep=""))
    data.df <- ncvar_get(nc.file, vars[v])
    time.df <- ncvar_get(nc.file, "time" )    
    lat     <- ncvar_get(nc.file, "lat" )
    lon     <- ncvar_get(nc.file, "lon" )
    nc_close(nc.file)
    
    # Looping through days to find the mean
    # NOTE: na.rm=F so that if there's a problem with missing data, we'll find it
    # NOTE: the time stap will be the first day of the month (consistent with how)
    #       the sub-daily timestamps work
	dat.temp  <- apply(data.df, 1:2, mean, na.rm=F)
	time.temp <- min(time.df)

    if (exists("dat.new")) { # if we already have created the new objects to store everything, append the new info
      dat.new <- abind(dat.new, dat.temp, along=3) 
      nc.time <- c(nc.time, time.temp)
    } else { # if the new objects don't exist, put the current data there
      dat.new <- dat.temp
      nc.time <- time.temp
    }

   } # close file loop

    # convert decimal days to just day ID & setting up dim defs
    nc_time_units <- paste('days since 0850-01-01 00:00:00', sep='')
    dim.time      <- ncdim_def("time",nc_time_units,nc.time,unlim=TRUE)
    

    # Print correct units 
	if (vars[v] == 'tmin') {
      nc_variable_long_name='2 meter air temperature, mean monthly minimum'
      nc_variable_units='K'
    } else if (vars[v] == 'tmax') {
      nc_variable_long_name='2 meter air temperature, mean monthly maximum'
      nc_variable_units='K'
    }
    
    # Make a few dimensions we can use
    dimY <- ncdim_def( "lat", "longitude: degrees", lat )
    dimX <- ncdim_def( "lon", "latitude: degrees", lon )
     
    nc_var  <- ncvar_def(vars[v],nc_variable_units,
                            list(dimX,dimY,dim.time), fillv, longname=nc_variable_long_name,prec="double")
    
    ofname  <- paste(file.path(outpath,paste0(vars[v],'.nc')))
    newfile <- nc_create( ofname, nc_var ) # Initialize file 
    
    ncatt_put( newfile, nc_var, 'days since 850', nc.time)
    ncatt_put( newfile, 0, 'description',"PalEON formatted Phase 1 met driver")
 
    ncvar_put(newfile, nc_var, dat.new) # Write netCDF file
    
    nc_close(newfile)  
	rm(dat.new, nc.time, nc_var, newfile)
} # Close variable loop
# -------------------------------------------------------------------------



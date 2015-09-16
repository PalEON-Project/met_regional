#correct the PalEON met driver timestamps to a uniform format
#Original: Jaclyn Hatala Matthes, 3/20/14, jaclyn.hatala.matthes@gmail.com
#Edits: Christy Rollinson, crollinson@gmail.com
#       January   2015: code clean-up, annotation
#       September 2015: add step to add mask here since CRU, CCSM4 p1000, & 
#                       CCSM4 historical all have slightly different masks
#

library(ncdf4)

basedir <- "/projectnb/dietzelab/paleon/met_regional/bias_corr/final_output_v2/"
outpath <- "/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp_v2/"

if(!dir.exists(outpath)) dir.create(outpath)

vars  <- c("lwdown","precipf","psurf","qair","swdown","tair","wind")
dpm   <- c(31,28,31,30,31,30,31,31,30,31,30,31) #days per month
dpm.l <- c(31,29,31,30,31,30,31,31,30,31,30,31) #leap year days per month
mv    <- 1e30    # Missing value
fillv   <- 1e+30

# We're having issues with non-consistent projections among the data, 
# so we're going to to use precipf 0850-01-01 as a mask because it has the fewest
# cells (there's a 1-cell discrpeency with that and post-1850; CRUNCEP has a lot more
# cells)

# Using the first precipf file as my mask
nc.mask <- nc_open(file.path(basedir, "precipf", "precipf_0850_01.nc"))
df.mask <- ncvar_get(nc.mask, "precipf")[,,1]
df.mask[!is.na(df.mask)] <- 1 # Convert it to binary to mimic the way Jackie did some masking in fix_precip_regional
nc_close(nc.mask)


for(v in 1:length(vars)){
  print(paste("--------------------", vars[v], "--------------------", sep=" "))
  files <- list.files(paste(basedir,vars[v],"/",sep=""))
  
  d <- -1
  for(f in 1:length(files)){
    nc.file <- nc_open(paste(basedir,vars[v],"/",files[f],sep=""))
    data <- ncvar_get(nc.file,vars[v])
    lat <- ncvar_get(nc.file,"lat")
    lon <- ncvar_get(nc.file,"lon")
    nc_close(nc.file)
    
    # Masking everything to our pre-defined, common mask
    # I couldn't find a faster way to do this outside of a loop, so a loop it is
    for(i in 1:(length(data[1,1,]))){
      data[,,i] <- data[,,i]*df.mask
    }
      
    #format time as days since 850-01-01 midnight
    tmp  <- strsplit(files[f],"_")
    year <- as.numeric(tmp[[1]][2])
    mon  <- as.numeric(substring(tmp[[1]][3],1,2))
    print(year)
    if((year%%4==0 & year%%100!=0) | year%%400==0){ # Leap Year
	  print(paste("-- Leap Year! --", sep=""))
      nc_time_units <- paste('days since 0850-01-01 00:00:00', sep='')
      t.start       <- d+1
      t.end         <- d+dpm.l[mon]
      nc.time       <- seq(t.start,t.end+0.75,by=0.25)
      time          <- ncdim_def("time",nc_time_units,nc.time,unlim=TRUE)
      d <- d + dpm.l[mon]
    } else {
      nc_time_units <- paste('days since 0850-01-01 00:00:00', sep='')
      t.start       <- d+1
      t.end         <- d+dpm[mon]
      nc.time       <- seq(t.start,t.end+0.75,by=0.25)
      time          <- ncdim_def("time",nc_time_units,nc.time,unlim=TRUE)
      d <- d + dpm[mon]
    }
 
    # Print correct units 
    if (vars[v] == 'lwdown') {
      nc_variable_long_name=paste('Incident (downwelling) longwave ',
                                  'radiation averaged over the time step of the forcing data', sep='')
      nc_variable_units='W m-2'
    } else if (vars[v] == 'precipf') {
      nc_variable_long_name=paste('The per unit area and time ',
                                  'precipitation representing the sum of convective rainfall, ',
                                  'stratiform rainfall, and snowfall', sep='')
      nc_variable_units='kg m-2 s-1'
    } else if (vars[v] == 'psurf') {
      nc_variable_long_name='Pressure at the surface'
      nc_variable_units='Pa'
    } else if (vars[v] == 'qair') {
      nc_variable_long_name=
        'Specific humidity measured at the lowest level of the atmosphere'
      nc_variable_units='kg kg-1'
    } else if (vars[v] == 'swdown') {
      nc_variable_long_name=paste('Incident (downwelling) radiation in ',
                                  'the shortwave part of the spectrum averaged over the time ',
                                  'step of the forcing data', sep='')
      nc_variable_units='W m-2'
    } else if (vars[v] == 'tair') {
      nc_variable_long_name='2 meter air temperature'
      nc_variable_units='K'
    } else if (vars[v] == 'wind') {
      nc_variable_long_name='Wind speed'
      nc_variable_units='m s-1'
    }
    
    # Make a few dimensions we can use
    dimY <- ncdim_def( "lat", "longitude: degrees", lat )
    dimX <- ncdim_def( "lon", "latitude: degrees", lon )
#    dimT <- ncdim_def( "time",nc_time_units,nc.time,unlim=TRUE)
     
    nc_var  <- ncvar_def(vars[v],nc_variable_units,
                            list(dimX,dimY,time), fillv, longname=nc_variable_long_name,prec="double")
    
    ofname  <- paste(outpath,vars[v],"/",vars[v],"_",sprintf('%04i',year),'_',
                   sprintf('%02i',mon),'.nc',sep="")
    newfile <- nc_create( ofname, nc_var ) # Initialize file 
    
    ncatt_put( newfile, nc_var, 'days since 850', nc.time)
    ncatt_put( newfile, 0, 'description',"PalEON formatted Phase 1 met driver")
 
    ncvar_put(newfile, nc_var, data) # Write netCDF file
    
    nc_close(newfile)  

  }
}



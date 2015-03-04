#add leap years to PalEON met drivers
# original: Jaclyn Hatala Matthes, 1/27/14, jaclyn.hatala.matthes@gmail.com
# edits: Christy Rollinson, January 2015, crollinson@gmail.com

library(ncdf4)
library(abind)

basedir <- "/projectnb/dietzelab/paleon/met_regional/bias_corr/final_output/"

#sites <- c("PBL","PHA","PHO","PUN","PDL","PMB")
vars  <- c("lwdown","precipf","psurf","qair","swdown","tair","wind")
dpm   <- 29 #leap year days per month
mv    <- 1e30    # Missing value

#for(s in 1:length(sites)){  
#  print(sites[s])
for(v in 1:length(vars)){
  print(vars[v])
  files <- list.files(paste(basedir,"/",vars[v],"/",sep=""),pattern = "\\_02.nc$")
  
  for(f in 1:length(files)){
    tmp  <- strsplit(files[f],"_")
    year <- as.numeric(tmp[[1]][2])
    print(year)
    
    #test if leap year
      if((year%%4==0 & year%%100!=0) | year%%400==0){
      print("Got here!")
      nc.file <- nc_open(paste(basedir,vars[v],"/",files[f],sep=""))
      var  <- ncvar_get(nc.file,vars[v])
      var.new <- abind(var[,,1:112],var[,,109:112],along=3) #copy Feb 28th to 29th
      lat <- ncvar_get(nc.file,"lat")
      lon <- ncvar_get(nc.file,"lon")
      nc_close(nc.file)
      
      # Specify time units for this year and month
      nc_time_units=paste('days since ', sprintf('%04i',year), '-',
                          sprintf('%02i',2), '-01 00:00:00', sep='')
      
      # Declare time dimension
      time <- seq(0,28.75,by=0.25)
      
      # Print correct units 
      if (vars[v] == 'lwdown') {
        nc_variable_long_name=paste('Incident (downwelling) longwave ',
                                    'radiation averaged over the time step of the forcing data', sep='')
        nc_variable_units='W m-2'
      }
      else if (vars[v] == 'precipf') {
        nc_variable_long_name=paste('The per unit area and time ',
                                    'precipitation representing the sum of convective rainfall, ',
                                    'stratiform rainfall, and snowfall', sep='')
        nc_variable_units='kg m-2 s-1'
      }
      else if (vars[v] == 'psurf') {
        nc_variable_long_name='Pressure at the surface'
        nc_variable_units='Pa'
      }
      else if (vars[v] == 'qair') {
        nc_variable_long_name=
          'Specific humidity measured at the lowest level of the atmosphere'
        nc_variable_units='kg kg-1'
      }
      else if (vars[v] == 'swdown') {
        nc_variable_long_name=paste('Incident (downwelling) radiation in ',
                                    'the shortwave part of the spectrum averaged over the time ',
                                    'step of the forcing data', sep='')
        nc_variable_units='W m-2'
      }
      else if (vars[v] == 'tair') {
        nc_variable_long_name='2 meter air temperature'
        nc_variable_units='K'
      }
      else if (vars[v] == 'wind') {
        nc_variable_long_name='Wind speed'
        nc_variable_units='m s-1'
      }
      
      # Make a few dimensions we can use
      dimX <- ncdim_def( "lon", "longitude: degrees", lon )
      dimY <- ncdim_def( "lat", "latitude: degrees", lat )
      dimT <- ncdim_def( "time",nc_time_units, time)
      
      var.nc <- ncvar_def(vars[v],nc_variable_units, list(dimX,dimY,dimT), mv,prec="double") #set up variable
      
      nc <- nc_create(paste(basedir,"/",vars[v],"/",files[f],sep=""), list(var.nc) ) # Create the test file
      ncvar_put(nc, var.nc, var.new ) # Write some data to the file
      
      # Add global attributes
      ncatt_put( nc, 0, 'description',"Repeated Feb 28th for leap year")
      nc_close(nc)  
      
    }
  }
}
#}




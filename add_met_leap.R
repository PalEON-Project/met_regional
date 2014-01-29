#add leap years to PalEON met drivers
#Jaclyn Hatala Matthes, 1/27/14
#jaclyn.hatala.matthes@gmail.com

library(ncdf,lib.loc="/usr4/spclpgm/jmatthes/")

basedir <- "/projectnb/cheas/paleon/met_regional/phase1a_met_drivers/bias_corr/"

sites <- c("PBL","PHA","PHO","PUN","PDL","PMB")
vars  <- c("lwdown","precipf","psurf","qair","swdown","tair","wind")
dpm   <- 29 #leap year days per month
mv    <- 1e30    # Missing value

for(s in 1:length(sites)){  
  print(sites[s])
  for(v in 1:length(vars)){
    print(vars[v])
    files <- list.files(paste(basedir,sites[s],"/",vars[v],"/",sep=""),pattern = "\\_02.nc$")
    
    for(f in 1:length(files)){
      tmp  <- strsplit(files[f],"_")
      year <- as.numeric(tmp[[1]][3])
      print(year)
      
      #test if leap year
      if((year%%4==0 & year%%100!=0) | year%%400==0){
        print("Got here!")
        nc.file <- open.ncdf(paste(basedir,sites[s],"/",vars[v],"/",files[f],sep=""))
        var  <- get.var.ncdf(nc.file,vars[v])
        var.new <- c(var,var[109:112]) #copy Feb 28th to 29th
        lat <- get.var.ncdf(nc.file,"lat")
        lon <- get.var.ncdf(nc.file,"lon")
        close.ncdf(nc.file)
    
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
        dimX <- dim.def.ncdf( "lat", "longitude: degrees", lat )
        dimY <- dim.def.ncdf( "lon", "latitude: degrees", lon )
        dimT <- dim.def.ncdf( "time",nc_time_units, time)
      
        var.nc <- var.def.ncdf(vars[v],nc_variable_units, list(dimX,dimY,dimT), mv,prec="double") #set up variable
        
        nc <- create.ncdf(paste(basedir,sites[s],"/",vars[v],"/",files[f],sep=""), list(var.nc) ) # Create the test file
        put.var.ncdf(nc, var.nc, var.new ) # Write some data to the file
           
        # Add global attributes
        att.put.ncdf( nc, 0, 'description',"Repeated Feb 28th for leap year")
        close.ncdf(nc)  

      }
    }
  }
}




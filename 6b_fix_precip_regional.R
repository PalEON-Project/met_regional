#Eliminate small values in the neural network output for precipitation.
#You MUST run format_nadp.R before this code to format the raw NADP site data.
#1. Find daily rainfall distribution based on nearest NADP sites across the PalEON domain.
#2. Test distribution of PalEON daily rainfall against NADP rainfall.
#3. Aggregate too-low precip by probability based on difference b/w data and model distributions.
#Original: Jaclyn Hatala Matthes, 4/10/14
#Edits: Christy Rollinson, January 2015

library(ncdf4)
library(date)
library(chron)
library(abind)

# Calculates the geodesic distance between two points specified by radian latitude/longitude using the
# Spherical Law of Cosines (slc)
gcd.slc <- function(long1, lat1, long2, lat2) {
  R <- 6371 # Earth mean radius [km]
  d <- acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2) * cos(long2-long1)) * R
  return(d) # Distance in km
}

# Convert degrees to radians
deg2rad <- function(deg) return(deg*pi/180)

#NADP data to get precip distribution
nd.path    <- '/projectnb/dietzelab/paleon/met_regional/fix_precip/nadp/'
nd.files   <- list.files(paste(nd.path,'allsites/',sep=''))

#PALEON down-scaled 6-hourly precipitation
basedir <- '/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp_v2/precipf/'
outpath <- '/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp_v2/precipf_corr/'

if(!dir.exists(outpath)) dir.create(outpath)

pl.files <- list.files(basedir)
#beg.yr  <- 850
beg.yr  <- 1582
end.yr  <- 2010
n.samps <- 50 # original was 500 (13.5 min/yr), but reduced to 100 for speed (3 min/yr)

#open 1 file to make PalEON mask
nc.file <- nc_open(paste(basedir,'precipf_0850_01.nc',sep=''))
data <- ncvar_get(nc.file,'precipf')
time <- ncvar_get(nc.file,'time')
lat  <- ncvar_get(nc.file,'lat')
lon  <- ncvar_get(nc.file,'lon')
nc_close(nc.file)
ll.grid <- expand.grid(lon,lat)
pl.mask <- data[,,1]
pl.mask[!is.na(pl.mask)] <- 1

#constants
dpm   <- c(1,31,28,31,30,31,30,31,31,30,31,30,31) #days per month
dpm.l <- c(1,31,29,31,30,31,30,31,31,30,31,30,31) #leap year days per month
inch2mm <- 2.54*10
day2sec <- 1/(24*60*60)
sec26hr <- 60*60*6
fillv   <- 1e+30
p.break <- seq(0,1000,by=1.0)

#load formatted NADP data saved from format_nadp.R
load('/projectnb/dietzelab/paleon/met_regional/fix_precip/NADP_daily.Rdata')

#loop through data and correct distributions
for(y in beg.yr:end.yr){
  
  for(m in 1:12){
    
    #open down-scaled 6-hourly mean precip file for each month
    year.now  <-sprintf('%4.4i',y)
    month.now <- sprintf('%2.2i',m)
    nc.file <- nc_open(paste(basedir,'precipf_',
                               year.now,'_',month.now,'.nc',sep=''))
    data <- ncvar_get(nc.file,'precipf')
    time <- ncvar_get(nc.file,'time')
    lat  <- ncvar_get(nc.file,'lat')
    lon  <- ncvar_get(nc.file,'lon')
    nc_close(nc.file)
    ll.grid <- expand.grid(lon,lat)
    
    #convert 6-hourly mean to daily sums
    for(n in 1:(length(data[1,1,])/4)){
      ind <- ((n-1)*4+1):(n*4)
      dat.day <- apply(data[,,ind]*sec26hr, c(1,2), sum)
      if(n==1){
        dat.mn <- dat.day
      } else{
        dat.mn <- abind(dat.mn,dat.day,along=3)
      }
    }
 
    #aggregate daily sums over one year
    if(m==1){
      dat.yr <- dat.mn
    } else {
      dat.yr <- abind(dat.yr,dat.mn,along=3)
    }
  }

  for(p in 1:length(dat.yr[,,1])){ #over each point in map
    
    print(paste("Point: ",p,sep=""))
    
    #match indices for that point
    lat.ind <- which(lat==ll.grid[p,2])
    lon.ind <- which(lon==ll.grid[p,1])
    ndp.ind <- which(nd.site.info$siteid==nearest.nadp[p])
    ndp.agg <- nd.daily[[ndp.ind]]
    
    if(!is.na(dat.yr[lon.ind,lat.ind,1])){ #only if point has data
      
      #replace any NAN with zero
      if(is.na(mean(dat.yr[lon.ind,lat.ind,]))){
        dat.yr[lon.ind,lat.ind,which(is.na(dat.yr[lon.ind,lat.ind,]))] <- 0.00000
      }
      
      #correct daily precip frequency distribution
      for(i in 1:n.samps){
        dat.vec <- as.vector(dat.yr[lon.ind,lat.ind,])
        x.pl  <- hist(dat.yr[lon.ind,lat.ind,], breaks=p.break,plot=FALSE)
        n     <- sample(1:(length(dat.yr[lon.ind,lat.ind,])-1), 1) #randomly pick a value
        if(dat.yr[lon.ind,lat.ind,n]!=0 & dat.yr[lon.ind,lat.ind,(n+1)]!=0){ #if no adjacent zero values
          x.sum <- dat.yr[lon.ind,lat.ind,n] + dat.yr[lon.ind,lat.ind,(n+1)]
          x.ind <- which.min(abs(x.pl$mids - x.sum)) #find freq bin
          
          #probability that the value should be replaced by sum
          #i.e. how far is the sum off from the data distribution
          if(x.pl$density[x.ind] > ndp.agg[x.ind]){
            samp.prob <- 1 - ndp.agg[x.ind]/x.pl$density[x.ind] 
          } else if(x.pl$density[x.ind] < ndp.agg[x.ind]){ 
            samp.prob <- 1 - x.pl$density[x.ind]/ndp.agg[x.ind]
          }
          
          #flip coin with prob based on difference b/w data & model output
          samp <- rbinom(1,1,samp.prob)
          if(samp){
            dat.yr[lon.ind,lat.ind,which(dat.yr[lon.ind,lat.ind,(n:(n+1))]==
                                           min(dat.yr[lon.ind,lat.ind,(n:(n+1))]))+n-1] <- 0
            dat.yr[lon.ind,lat.ind,which(dat.yr[lon.ind,lat.ind,(n:(n+1))]==
                                           max(dat.yr[lon.ind,lat.ind,(n:(n+1))]))+n-1] <- x.sum
          }
        }
      }
      
      dat.vec <- as.vector(dat.yr[lon.ind,lat.ind,])
      if(mean(dat.vec[dat.vec>0])>100 | mean(dat.vec[dat.vec>0])<0.01){
        print(paste('Warning! Tear: ',y,', Mean: ',mean(dat.vec[dat.vec>0]),sep=''))
      }
    } #end loop if data is not NA - otherwise do nothing
  } #end loop over each point
  
  #write new 6-hourly netCDF file for each month
  for(m in 1:12){
    
    #need to open file to get time
    year.now  <-sprintf('%4.4i',y)
    month.now <- sprintf('%2.2i',m)
    nc.file   <- nc_open(paste(basedir,'precipf_',
                                 year.now,'_',month.now,'.nc',sep=''))
    data <- ncvar_get(nc.file,'precipf')
    lat <- ncvar_get(nc.file,'lat')
    lon <- ncvar_get(nc.file,'lon')
    nc.time <- ncvar_get(nc.file,'time')
    nc_close(nc.file)
    
    nc_time_units <- paste('days since 0850-01-01 00:00:00', sep='')
    time          <- ncdim_def('time',nc_time_units,nc.time,unlim=TRUE)
    if((y%%4==0 & y%%100!=0) | y%%400==0){
      days          <- dpm.l
    } else {
      days          <- dpm
    }
    
    #dump all daily precip into old maximum daily 6-hour bin
    data.new <- array(data = 0, dim = dim(data))
    for(p in 1:length(dat.yr[,,1])){ #over each point in map
      
      #match indices for that point
      lat.ind <- which(lat==ll.grid[p,2])
      lon.ind <- which(lon==ll.grid[p,1])
      
      if(!is.na(dat.yr[lon.ind,lat.ind,1])){
        #split corrected daily precip into old max bin
        for(v in 1:(length(data[lon.ind,lat.ind,])/4)){
          old.ind  <- ((v-1)*4+1):(v*4)
          yr.ind   <- cumsum(days)[m]:(cumsum(days)[m+1]-1)
          data.new[lon.ind,lat.ind,which(data[lon.ind,lat.ind,]==max(data[lon.ind,lat.ind,old.ind]))] <- 
            dat.yr[lon.ind,lat.ind,(v+cumsum(days)[m]-1)]*day2sec*4
        }
      }
    }
    
    #mask domain to NAs, leaving zeroes
    for(v in 1:(length(data[1,1,]))){
      data.new[,,v] <- data.new[,,v]*pl.mask
    }
    
    #print correct units 
    nc_variable_long_name=paste('The per unit area and time ',
                                'precipitation representing the sum of convective rainfall, ',
                                'stratiform rainfall, and snowfall; EDITED to aggregate too-low precip ',
                                'values to match distribution of NADP sites', sep='')
    nc_variable_units='kg m-2 s-1'
    
    #make new 6-hourly netCDF file
    dimY <- ncdim_def( 'lat', 'latitude: degrees', lat )
    dimX <- ncdim_def( 'lon', 'longitude: degrees', lon )
#    dimT <- ncdim_def( 'time',nc_time_units, time)
    
    nc_var  <- ncvar_def('precipf',nc_variable_units,
                            list(dimX,dimY,time), fillv, longname=nc_variable_long_name,prec='double')
    
    ofname  <- paste(outpath,'precipf_',sprintf('%04i',y),'_',
                     sprintf('%02i',m),'.nc',sep='')
    newfile <- nc_create(ofname, nc_var) # Initialize file 
    
    ncatt_put( newfile, nc_var, 'days since 850', nc.time)
    ncatt_put( newfile, 0, 'description','PalEON formatted Phase 1 met driver')
    
    ncvar_put(newfile, nc_var, data.new) # Write netCDF file
    
    nc_close(newfile)  
    
  }
}




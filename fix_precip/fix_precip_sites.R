#Eliminate small values in the neural network output for precipitation.
#1. Find daily rainfall distribution based on nearest NADP sites.
#2. Test distribution of PalEON daily rainfall against NADP rainfall.
#3. Aggregate too-low precip by probability based on difference b/w data and model distributions.
#Original: Jaclyn Hatala Matthes, 4/10/14
#Edits: Christy Rollinson, January 2015, crollinson@gmail.com

library(ncdf4)

#NADP data to get precip distribution
nd.path    <- "/projectnb/dietzelab/paleon/met_regional/fix_precip/nadp/"
nd.files   <- list.files(nd.path)
pl.sites   <- c("PHA","PHO","PMB","PUN","PBL","PDL")
nd.sites   <- c("MA08","ME09","MI09","WI36","MN16","MN16")

#PALEON down-scaled 6-hourly precipitation
basedir <- "/projectnb/dietzelab/paleon/met_regional/phase1a_met_drivers_v4.1/"
outpath <- "/projectnb/dietzelab/paleon/met_regional/phase1a_met_drivers_v4.1/precipf_corr/"
beg.yr  <- 850
end.yr  <- 2010
n.samps <- 50

#constants
dpm   <- c(1,31,28,31,30,31,30,31,31,30,31,30,31) #days per month
dpm.l <- c(1,31,29,31,30,31,30,31,31,30,31,30,31) #leap year days per month
inch2mm <- 2.54*10
day2sec <- 1/(24*60*60)
sec26hr <- 60*60*6
fillv   <- 1e+30

for(s in 1:length(pl.sites)){
#s <- 3
  nd.dat <- read.csv(paste(nd.path,nd.files[grep(nd.sites[s],nd.files)],sep=""),header=TRUE,skip=2)
  nd.dat[nd.dat==-9 | nd.dat==-7] <- NA #replace NADP data NA & "trace" values
  
  #calculate mean annual precip frequency distirbution from NADP site
  nd.yrs <- unique(floor(nd.dat$year))
  for(y in nd.yrs){
    yr.dat <- nd.dat[which(floor(nd.dat$year)==y),]
    yr.ppt <- tapply(yr.dat$Amount, yr.dat$doy, sum, na.rm=T)
    
    p.break <- seq(0,1000,by=1.0)
    x.nd <- hist(yr.ppt[yr.ppt>0]*inch2mm,breaks=p.break,plot=FALSE)
    
    if(y==min(nd.yrs)){
      nd.agg <- as.vector(x.nd$density)
    } else{
      nd.agg <- apply(cbind(nd.agg,as.vector(x.nd$density)),1,mean,na.rm=TRUE)
    } 
  }
  
  #load ANN down-scaled PalEON data
  for(y in beg.yr:end.yr){
    for(m in 1:12){
      year.now  <-sprintf("%4.4i",y)
      month.now <- sprintf("%2.2i",m)
      nc.file <- nc_open(paste(basedir,pl.sites[s],
                                 "/precipf/",pl.sites[s],"_precipf_",
                                 year.now,"_",month.now,".nc",sep=""))
      data <- ncvar_get(nc.file,"precipf")
      time <- ncvar_get(nc.file,"time")
      nc_close(nc.file)
      
      dat.mn <- tapply(data*sec26hr, (seq_along(time)-1) %/% 4, sum, na.rm=T)
      
      if(m==1){
        dat.yr <- as.vector(dat.mn)
      } else {
        dat.yr <- c(dat.yr,as.vector(dat.mn))
      }
    }
    
    #correct daily precip frequency distribution
    for(i in 1:n.samps){
      x.pl  <- hist(dat.yr[dat.yr>0], breaks=p.break,plot=FALSE)
      n     <- sample(1:(length(dat.yr)-1), 1) #randomly pick a value
      if(n!=0 & (n+1)!=0){ #if no adjacent zero values
        x.sum <- dat.yr[n] + dat.yr[n+1]
        x.ind <- which.min(abs(x.pl$mids - x.sum)) #find freq bin

        #probability that the value should be replaced by sum
        #i.e. how far is the sum off from the data distribution
        if(x.pl$density[x.ind] > nd.agg[x.ind]){
          samp.prob <- 1 - nd.agg[x.ind]/x.pl$density[x.ind] 
        } else if(x.pl$density[x.ind] < nd.agg[x.ind]){ 
          samp.prob <- 1 - x.pl$density[x.ind]/nd.agg[x.ind]
        }
        
        #flip coin with prob based on difference b/w data & model output
        samp <- rbinom(1,1,samp.prob)
        if(samp){
          dat.yr[which(dat.yr[n:(n+1)]==min(dat.yr[n:(n+1)]))+n-1] <- 0
          dat.yr[which(dat.yr[n:(n+1)]==max(dat.yr[n:(n+1)]))+n-1] <- x.sum
        }
      }
    }
    
    if(mean(dat.yr[dat.yr>0])>100 | mean(dat.yr[dat.yr>0])<0.01){
      print(paste("Warning! site: ",pl.sites[s],", year: ",y,", month: ",m,", Mean: ",mean(dat.yr[dat.yr>0]),sep=""))
    }
    
    #write new 6-hourly netCDF file
    for(m in 1:12){
      year.now  <-sprintf("%4.4i",y)
      month.now <- sprintf("%2.2i",m)
      nc.file   <- nc_open(paste(basedir,pl.sites[s],
                                 "/precipf/",pl.sites[s],"_precipf_",
                                 year.now,"_",month.now,".nc",sep=""))
      data <- ncvar_get(nc.file,"precipf")
      lat <- ncvar_get(nc.file,"lat")
      lon <- ncvar_get(nc.file,"lon")
      nc.time <- ncvar_get(nc.file,"time")
      nc_close(nc.file)
      
      nc_time_units <- paste('days since 0850-01-01 00:00:00', sep='')
      time          <- ncdim_def("time",nc_time_units,nc.time,unlim=TRUE)
      if((y%%4==0 & y%%100!=0) | y%%400==0){
        days          <- dpm.l
      } else {
        days          <- dpm
      }
      
      #dump all daily precip into old maximum daily 6-hour bin
      data.new <- rep(0,length(data))
      for(v in 1:(length(data)/4)){
        old.ind  <- ((v-1)*4+1):(v*4)
        yr.ind   <- cumsum(days)[m]:(cumsum(days)[m+1]-1)
        data.new[which(data==max(data[old.ind]))] <- dat.yr[v+cumsum(days)[m]-1]*day2sec*4
      }
      
      #print correct units 
      nc_variable_long_name=paste('The per unit area and time ',
                                  'precipitation representing the sum of convective rainfall, ',
                                  'stratiform rainfall, and snowfall; EDITED to aggregate too-low precip ',
                                  'values to match distribution of NADP sites', sep='')
      nc_variable_units='kg m-2 s-1'
      
      #make new 6-hourly netCDF file
      dimY <- ncdim_def( "lat", "latitude: degrees", lat )
      dimX <- ncdim_def( "lon", "longitude: degrees", lon )
#      dimT <- ncdim_def( "time",nc_time_units, time)
      
      nc_var  <- ncvar_def("precipf",nc_variable_units,
                              list(dimX,dimY,time), fillv, longname=nc_variable_long_name,prec="double")
      
      ofname  <- paste(basedir,pl.sites[s],"/precipf_corr/",pl.sites[s],"_precipf_",sprintf('%04i',y),'_',
                       sprintf('%02i',m),'.nc',sep="")
      newfile <- nc_create(ofname, nc_var) # Initialize file 
      
	  ncatt_put( newfile, nc_var, 'days since 850', nc.time)
      ncatt_put( newfile, 0, 'description',"PalEON formatted Phase 1 met driver")
      
      ncvar_put(newfile, nc_var, data.new) # Write netCDF file
      
      nc_close(newfile)  
      
    }

  }
}


#check the output values to make sure they look good




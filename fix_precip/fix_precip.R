#Eliminate small values in the neural network output for precipitation.
#1. Find empirical threshold based on Ameriflux sites
#2. Flag precip data below threshold in precip driver.
#3. Cumulatively aggregate too-low precip until over threshold.
#Jaclyn Hatala Matthes, 4/10/14

library(ncdf,lib.loc="/usr4/spclpgm/jmatthes/")
library(reshape2,lib.loc="/usr4/spclpgm/jmatthes/")
library(ggplot2,lib.loc="/usr4/spclpgm/jmatthes/")

#FIRST USE AMERIFLUX DATA TO LOOK FOR MIN PRECIP VALUE
af.path <- "/projectnb/cheas/paleon/met_regional/fix_precip/ameriflux/"
af.file <- list.files(af.path)
sites   <- c("Ha1","Ho1","UMB")
window.avg <- 24

min.6hr <- max.6hr <- med.6hr <- low.6hr <- list()
for(f in 1:length(af.file)){
  dat <- read.csv(paste(af.path,af.file[f],sep=""),header=TRUE)
  dat[dat==-9999] <- NA

#   #figure out if data are hourly/half-hourly
#   time.check <- diff(dat[dat[,1]>=2007 & dat[,1]<2008,1])*365
#   if(time.check[1]*24>0.9){ #if hourly
#     time.stat <- 1
#   } else if(time.check[1]*24<0.9){ #if half-hourly
#     time.stat <- 2
#   } else{
#     print("Warning! Ameriflux time is weird.")
#   }
#   
  #calculate annual precip distirbution
  af.yrs <- unique(floor(dat[,1]))
  min.6hr[[f]] <- max.6hr[[f]] <- low.6hr[[f]] <- med.6hr[[f]] <- vector(length=length(af.yrs))
  for(y in af.yrs){
    yr.dat <- dat[which(floor(dat[,1])==y),2]
    
    if(length(yr.dat)>1){
      #mean 6-hourly precip: mm/(time.stat) = mm/hr --> mm/s
      yr.6hr <- tapply(yr.dat/(time.stat), (seq_along(yr.dat)-1) %/% (window.avg*time.stat), sum)/(window.avg*60*60)
      
      print(paste("Summer: ",mean(yr.6hr[200:300][which(yr.6hr[200:300]>0)],na.rm=TRUE),sep=""))
      print(paste("Winter: ",mean(yr.6hr[1:100][which(yr.6hr[1:100]>0)],na.rm=TRUE),sep=""))
      
      if(sum(!is.na(yr.6hr))>1){
        hist(yr.6hr[yr.6hr>0]*(60*60*window.avg),main=paste(sites[f],": ",y,sep=""),
             xlab="Precip [mm/6hr]",ylab="density",breaks=c(seq(0,20,by=0.5),
                                                            max(yr.6hr[yr.6hr>0]*(60*60*window.avg),na.rm=TRUE)),xlim=c(0,100))
      }
      min.6hr[[f]][y-min(af.yrs)+1] <- min(yr.6hr[yr.6hr>0],na.rm=TRUE)
      max.6hr[[f]][y-min(af.yrs)+1] <- max(yr.6hr[yr.6hr>0],na.rm=TRUE)
      med.6hr[[f]][y-min(af.yrs)+1] <- median(yr.6hr[yr.6hr>0],na.rm=TRUE)
      low.6hr[[f]][y-min(af.yrs)+1] <- quantile(yr.6hr[yr.6hr>0], 0.05, na.rm = TRUE)
      
    } else{
      min.6hr[[f]][y-min(af.yrs)+1] <- NA
      max.6hr[[f]][y-min(af.yrs)+1] <- NA
      med.6hr[[f]][y-min(af.yrs)+1] <- NA
      low.6hr[[f]][y-min(af.yrs)+1] <- NA
    }
  }
}

#SECOND USE NADP DATA TO LOOK FOR MIN PRECIP VALUE
nd.path <- "/projectnb/cheas/paleon/met_regional/fix_precip/nadp/"
nd.file <- list.files(nd.path)
#sites   <- c("Ha1","Ho1","UMB")
#window.avg <- 24

min.6hr <- max.6hr <- med.6hr <- low.6hr <- list()
for(f in 1:length(nd.file)){
  dat <- read.csv(paste(nd.path,nd.file[f],sep=""),header=TRUE,skip=2)
  dat[dat==-9999] <- NA
  
  #calculate annual precip distirbution
  nd.yrs <- unique(floor(dat$year))
  min.6hr[[f]] <- max.6hr[[f]] <- low.6hr[[f]] <- med.6hr[[f]] <- vector(length=length(af.yrs))
  for(y in nd.yrs){
    yr.dat <- dat[which(floor(dat$year)==y),]
    yr.ppt <- tapply(yr.dat$Amount, yr.dat$doy, sum)
    
    if(length(yr.dat)>366){
      #mean 6-hourly precip: mm/(time.stat) = mm/hr --> mm/s
      yr.6hr <- tapply(yr.dat/(time.stat), (seq_along(yr.dat)-1) %/% (window.avg*time.stat), sum)/(window.avg*60*60)
      
      print(paste("Summer: ",mean(yr.6hr[200:300][which(yr.6hr[200:300]>0)],na.rm=TRUE),sep=""))
      print(paste("Winter: ",mean(yr.6hr[1:100][which(yr.6hr[1:100]>0)],na.rm=TRUE),sep=""))
      
      if(sum(!is.na(yr.6hr))>1){
        hist(yr.6hr[yr.6hr>0]*(60*60*window.avg),main=paste(sites[f],": ",y,sep=""),
             xlab="Precip [mm/6hr]",ylab="density",breaks=c(seq(0,20,by=0.5),
                                                            max(yr.6hr[yr.6hr>0]*(60*60*window.avg),na.rm=TRUE)),xlim=c(0,100))
      }
      min.6hr[[f]][y-min(af.yrs)+1] <- min(yr.6hr[yr.6hr>0],na.rm=TRUE)
      max.6hr[[f]][y-min(af.yrs)+1] <- max(yr.6hr[yr.6hr>0],na.rm=TRUE)
      med.6hr[[f]][y-min(af.yrs)+1] <- median(yr.6hr[yr.6hr>0],na.rm=TRUE)
      low.6hr[[f]][y-min(af.yrs)+1] <- quantile(yr.6hr[yr.6hr>0], 0.05, na.rm = TRUE)
      
    } else{
      min.6hr[[f]][y-min(af.yrs)+1] <- NA
      max.6hr[[f]][y-min(af.yrs)+1] <- NA
      med.6hr[[f]][y-min(af.yrs)+1] <- NA
      low.6hr[[f]][y-min(af.yrs)+1] <- NA
    }
  }
}

#PLOT DAILY SUM PALEON PRECIP
basedir <- "/projectnb/cheas/paleon/met_regional/phase1b_met_regional/"
outpath <- "/projectnb/cheas/paleon/met_regional/phase1b_met_regional/corr_precipf/"
vars  <- "precipf"

dpm   <- c(31,28,31,30,31,30,31,31,30,31,30,31) #days per month
dpm.l <- c(31,29,31,30,31,30,31,31,30,31,30,31) #leap year days per month

beg.yr <- 850
end.yr <- 859

for(y in beg.yr:end.yr){
  for(m in 1:12){
    year.now  <-sprintf("%4.4i",y)
    month.now <- sprintf("%2.2i",m)
    nc.file <- open.ncdf(paste(basedir,"precipf/precipf_",year.now,"_",month.now,".nc",sep=""))
    data <- get.var.ncdf(nc.file,"precipf")
    lat  <- get.var.ncdf(nc.file,"lat")
    lon  <- get.var.ncdf(nc.file,"lon")
    time <- get.var.ncdf(nc.file,"time")
    close.ncdf(nc.file)
    HF.lat <- which(lat==42.75)
    HF.lon <- which(lon==-72.25)
    dat.mn <- tapply(data[HF.lon,HF.lat,]*(60*60*6), (seq_along(time)-1) %/% 4, sum)
    
    if(m==1){
      dat.yr <- as.vector(dat.mn)
    } else {
      dat.yr <- c(dat.yr,as.vector(dat.mn))
    }
    
    bucket <- list(a=dat.yr[dat.yr>0],b=yr.ppt[yr.ppt>0]*2.54*10) # this puts all values in one list
    
    ggplot(melt(bucket), aes(value, fill = L1)) + 
      geom_histogram(position = "dodge", binwidth=2)
  }
}


#THEN USE MIN VALUE TO FIX PALEON PRECIP
low.lim <- mean(c(mean(low.6hr[[1]],na.rm=TRUE),mean(low.6hr[[2]],na.rm=TRUE),
                  mean(low.6hr[[3]],na.rm=TRUE)))

basedir <- "/projectnb/cheas/paleon/met_regional/phase1b_met_regional/"
outpath <- "/projectnb/cheas/paleon/met_regional/phase1b_met_regional/corr_precipf/"
vars  <- "precipf"

dpm   <- c(31,28,31,30,31,30,31,31,30,31,30,31) #days per month
dpm.l <- c(31,29,31,30,31,30,31,31,30,31,30,31) #leap year days per month
mv    <- 1e30    # Missing value
fillv   <- 1e+30

files <- list.files(paste(basedir,"precipf/",sep=""))
d <- -1
data.punt <- matrix(0,80,30)
for(f in 1:length(files)){
  nc.file <- open.ncdf(paste(basedir,"precipf/",files[f],sep=""))
  data <- get.var.ncdf(nc.file,"precipf")
  lat <- get.var.ncdf(nc.file,"lat")
  lon <- get.var.ncdf(nc.file,"lon")
  close.ncdf(nc.file)
  
  #format time as days since 850-01-01 midnight
  tmp  <- strsplit(files[f],"_")
  year <- as.numeric(tmp[[1]][2])
  mon  <- as.numeric(substring(tmp[[1]][3],1,2))
  print(year)
  if((year%%4==0 & year%%100!=0) | year%%400==0){
    nc_time_units <- paste('days since 0850-01-01 00:00:00', sep='')
    t.start       <- d+1
    t.end         <- d+dpm.l[mon]
    nc.time       <- seq(t.start,t.end+0.75,by=0.25)
    time          <- dim.def.ncdf("time",nc_time_units,nc.time,unlim=TRUE)
    d <- d + dpm.l[mon]
  } else {
    nc_time_units <- paste('days since 0850-01-01 00:00:00', sep='')
    t.start       <- d+1
    t.end         <- d+dpm[mon]
    nc.time       <- seq(t.start,t.end+0.75,by=0.25)
    time          <- dim.def.ncdf("time",nc_time_units,nc.time,unlim=TRUE)
    d <- d + dpm[mon]
  }
  
  for(t in 1:length(data[1,1,])){
    too.low <- which(data[,,t]>0 & data[,,t]<low.lim)
    if(t==1){ #in first timestep, add punted data from previous month
      data[,,t] <- data[,,t] + data.punt
      too.low <- which(data[,,t]>0 & data[,,t]<low.lim)
      data[,,(t+1)][too.low] <- data[,,(t+1)][too.low] + data[,,t][too.low]
      data[,,t][too.low] <- 0.0
    } else if(t == length(data[1,1,])){ #in last timestep, punt data to next month
      data.punt <- matrix(0, nrow(data), ncol(data))
      data.punt[too.low] <- data[,,t][too.low]
      data[,,t][too.low] <- 0.0
    } else{
      data[,,(t+1)][too.low] <- data[,,(t+1)][too.low] + data[,,t][too.low]
      data[,,t][too.low] <- 0.0 
    }
  }
  
  # Print correct units 
  nc_variable_long_name=paste('The per unit area and time ',
                              'precipitation representing the sum of convective rainfall, ',
                              'stratiform rainfall, and snowfall; EDITED to clip min precip values', sep='')
  nc_variable_units='kg m-2 s-1'
  
  # Make a few dimensions we can use
  dimY <- dim.def.ncdf( "lat", "longitude: degrees", lat )
  dimX <- dim.def.ncdf( "lon", "latitude: degrees", lon )
  dimT <- dim.def.ncdf( "time",nc_time_units, time)
  
  nc_var  <- var.def.ncdf("precipf",nc_variable_units,
                          list(dimX,dimY,time), fillv, longname=nc_variable_long_name,prec="double")
  
  ofname  <- paste(outpath,"precipf_",sprintf('%04i',year),'_',
                   sprintf('%02i',mon),'.nc',sep="")
  newfile <- create.ncdf( ofname, nc_var ) # Initialize file 
  
  att.put.ncdf( newfile, time, 'calendar', 'days since 850')
  att.put.ncdf( newfile, 0, 'description',"PalEON formatted Phase 1 met driver")
  
  put.var.ncdf(newfile, nc_var, data) # Write netCDF file
  
  close.ncdf(newfile)  
  
}





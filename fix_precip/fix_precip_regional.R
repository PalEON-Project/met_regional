#Eliminate small values in the neural network output for precipitation.
#1. Find daily rainfall distribution based on nearest NADP sites across the PalEON domain.
#2. Test distribution of PalEON daily rainfall against NADP rainfall.
#3. Aggregate too-low precip by probability based on difference b/w data and model distributions.
#Jaclyn Hatala Matthes, 4/10/14

library(ncdf,lib.loc="/usr4/spclpgm/jmatthes/")
library(spam,lib.loc="/usr4/spclpgm/jmatthes/")
library(fields,lib.loc="/usr4/spclpgm/jmatthes/")
library(sp,lib.loc="/usr4/spclpgm/jmatthes/")
library(Imap,lib.loc="/usr4/spclpgm/jmatthes/")
library(date,lib.loc="/usr4/spclpgm/jmatthes/")
library(chron,lib.loc="/usr4/spclpgm/jmatthes/")

#NADP data to get precip distribution
nd.path    <- "/projectnb/cheas/paleon/met_regional/fix_precip/nadp/"
nd.files   <- list.files(paste(nd.path,"allsites/",sep=""))

#list individual NADP sites
nd.sites <- vector()
for(f in 1:length(nd.files)){
  nd.sites[f] <- substring(nd.files[f],1,4)
}

#get NADP site lat lon
nd.site.info   <- read.csv(paste(nd.path,"nadp_sites.csv",sep=""),stringsAsFactors=FALSE)
nd.ind <- which(nd.site.info$siteid %in% nd.sites)
nd.site.info <- nd.site.info[nd.ind,c(1,7,8)]

#PALEON down-scaled 6-hourly precipitation
basedir <- "/projectnb/cheas/paleon/met_regional/phase1b_met_regional/precipf/"
outpath <- "/projectnb/cheas/paleon/met_regional/phase1b_met_regional/corr_precipf/"
pl.files <- list.files(basedir)
beg.yr  <- 850
end.yr  <- 2010
n.samps <- 500

#constants
dpm   <- c(1,31,28,31,30,31,30,31,31,30,31,30,31) #days per month
dpm.l <- c(1,31,29,31,30,31,30,31,31,30,31,30,31) #leap year days per month
inch2mm <- 2.54*10
day2sec <- 1/(24*60*60)
sec26hr <- 60*60*6
fillv   <- 1e+30

for(f in 1:length(pl.files)){ #over monthly down-scaled precip
  
  #open down-scaled netcdf file
  nc.file <- open.ncdf(paste(basedir,pl.files[f],sep=""))
  data <- get.var.ncdf(nc.file,"precipf")
  time <- get.var.ncdf(nc.file,"time")
  lat  <- get.var.ncdf(nc.file,"lat")
  lon  <- get.var.ncdf(nc.file,"lon")
  close.ncdf(nc.file)
  ll.grid <- expand.grid(lon,lat)
  
  for(t in 1:length(time)){ #over each 6-hour map
    dat.vec <- as.vector(data[,,t])
    new.dat.vec <- rep(NA,length=length(data))

    for(p in 1:length(dat.vec)){ #over each point in map
      if(!is.na(dat.vec[p])){ #only if point has data
  
        #find closest NADP station by latlon great circle distance
        dist <- gdist(lat.1=nd.site.info$latitude,lon.1=nd.site.info$longitude,lat.2=ll.grid[p,2],lon.2=ll.grid[p,1])
        near.file <- nd.site.info[which(dist==min(dist)),1]
        nd.near   <- read.csv(paste(nd.path,"allsites/",nd.files[grep(near.file,nd.files)],sep=""),
                              header=TRUE,skip=3,stringsAsFactors=FALSE)
        nd.near <- nd.near[2:nrow(nd.near),] #skip blank line between header and data
        nd.near[nd.near==-9 | nd.near==-7] <- NA #replace NADP data NA and "trace" values
        
        #parse dates
        nd.year <- nd.mon <- nd.day <- nd.doy <- vector()
        for(d in 1:nrow(nd.near)){
            yr.tmp <- strsplit(strsplit(nd.near$EndTime[d]," ")[[1]][1],"/")[[1]][3]
            nd.year[d] <- as.numeric(if(yr.tmp<20){paste("20",yr.tmp,sep="")}else{paste("19",yr.tmp,sep="")})
            nd.mon[d] <- as.numeric(strsplit(strsplit(nd.near$EndTime[d]," ")[[1]][1],"/")[[1]][1])
            nd.day[d] <- as.numeric(strsplit(strsplit(nd.near$EndTime[d]," ")[[1]][1],"/")[[1]][2])
            
            nd.doy[d] <- julian(nd.mon[d],nd.day[d],nd.year[d],origin=c(month=1,day=1,year=nd.year[d]))+1
        }
        
        nd.near <- cbind(nd.near,nd.year,nd.doy)
        
        #calculate mean annual precip frequency distirbution from NADP site
        nd.yrs <- unique(floor(nd.year))
        for(y in nd.yrs){
          yr.dat <- nd.near[which(floor(nd.year)==y),]
          yr.ppt <- tapply(yr.dat$Amount, yr.dat$doy, sum)
          
          p.break <- seq(0,1000,by=1.0)
          x.nd <- hist(yr.ppt[yr.ppt>0]*inch2mm,breaks=p.break,plot=FALSE)
          
          if(y==min(nd.yrs)){
            nd.agg <- as.vector(x.nd$density)
          } else{
            nd.agg <- apply(cbind(nd.agg,as.vector(x.nd$density)),1,mean,na.rm=TRUE)
          } 
        }
        
        
      }
      
    }
    
  }
  
  nd.dat <- read.csv(paste(nd.path,nd.files[grep(nd.sites[s],nd.files)],sep=""),header=TRUE,skip=2)
  nd.dat[nd.dat==-9 | nd.dat==-7] <- NA #replace NADP data NA & "trace" values
  
  #calculate mean annual precip frequency distirbution from NADP site
  nd.yrs <- unique(floor(nd.dat$year))
  for(y in nd.yrs){
    yr.dat <- nd.dat[which(floor(nd.dat$year)==y),]
    yr.ppt <- tapply(yr.dat$Amount, yr.dat$doy, sum)
    
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
      nc.file <- open.ncdf(paste(basedir,pl.sites[s],
                                 "/precipf/",pl.sites[s],"_precipf_",
                                 year.now,"_",month.now,".nc",sep=""))
      data <- get.var.ncdf(nc.file,"precipf")
      time <- get.var.ncdf(nc.file,"time")
      close.ncdf(nc.file)
      
      dat.mn <- tapply(data*sec26hr, (seq_along(time)-1) %/% 4, sum)
      
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
      print(paste("Warning! site: ",pl.sites[s],", year: ",y,", Mean: ",mean(dat.yr[dat.yr>0]),sep=""))
    }
    
    #write new 6-hourly netCDF file
    for(m in 1:12){
      year.now  <-sprintf("%4.4i",y)
      month.now <- sprintf("%2.2i",m)
      nc.file   <- open.ncdf(paste(basedir,pl.sites[s],
                                 "/precipf/",pl.sites[s],"_precipf_",
                                 year.now,"_",month.now,".nc",sep=""))
      data <- get.var.ncdf(nc.file,"precipf")
      lat <- get.var.ncdf(nc.file,"lat")
      lon <- get.var.ncdf(nc.file,"lon")
      nc.time <- get.var.ncdf(nc.file,"time")
      close.ncdf(nc.file)
      
      nc_time_units <- paste('days since 0850-01-01 00:00:00', sep='')
      time          <- dim.def.ncdf("time",nc_time_units,nc.time,unlim=TRUE)
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
      dimY <- dim.def.ncdf( "lat", "latitude: degrees", lat )
      dimX <- dim.def.ncdf( "lon", "longitude: degrees", lon )
      dimT <- dim.def.ncdf( "time",nc_time_units, time)
      
      nc_var  <- var.def.ncdf("precipf",nc_variable_units,
                              list(dimX,dimY,time), fillv, longname=nc_variable_long_name,prec="double")
      
      ofname  <- paste(outpath,pl.sites[s],"/",pl.sites[s],"_precipf_",sprintf('%04i',y),'_',
                       sprintf('%02i',m),'.nc',sep="")
      newfile <- create.ncdf(ofname, nc_var) # Initialize file 
      
      att.put.ncdf( newfile, time, 'calendar', 'days since 850')
      att.put.ncdf( newfile, 0, 'description',"PalEON formatted Phase 1 met driver")
      
      put.var.ncdf(newfile, nc_var, data.new) # Write netCDF file
      
      close.ncdf(newfile)  
      
    }

  }
}


#check the output values to make sure they look good




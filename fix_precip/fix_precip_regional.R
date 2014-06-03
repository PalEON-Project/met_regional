#Eliminate small values in the neural network output for precipitation.
#1. Find daily rainfall distribution based on nearest NADP sites across the PalEON domain.
#2. Test distribution of PalEON daily rainfall against NADP rainfall.
#3. Aggregate too-low precip by probability based on difference b/w data and model distributions.
#Jaclyn Hatala Matthes, 4/10/14

library(ncdf,lib.loc='/usr4/spclpgm/jmatthes/')
library(maps,lib.loc='/usr4/spclpgm/jmatthes/')
library(sp,lib.loc='/usr4/spclpgm/jmatthes/')
library(Imap,lib.loc='/usr4/spclpgm/jmatthes/')
library(date,lib.loc='/usr4/spclpgm/jmatthes/')
library(chron,lib.loc='/usr4/spclpgm/jmatthes/')
library(abind,lib.loc='/usr4/spclpgm/jmatthes/')

#options(warn=-1)

#NADP data to get precip distribution
nd.path    <- '/projectnb/cheas/paleon/met_regional/fix_precip/nadp/'
nd.files   <- list.files(paste(nd.path,'allsites/',sep=''))

#list individual NADP sites
nd.sites <- vector()
for(f in 1:length(nd.files)){
  nd.sites[f] <- substring(nd.files[f],1,4)
}

#get NADP site lat lon
nd.site.info   <- read.csv(paste(nd.path,'nadp_sites.csv',sep=''),stringsAsFactors=FALSE)
nd.ind <- which(nd.site.info$siteid %in% nd.sites)
nd.site.info <- nd.site.info[nd.ind,c(1,7,8)]

#PALEON down-scaled 6-hourly precipitation
basedir <- '/projectnb/cheas/paleon/met_regional/phase1b_met_regional/precipf/'
outpath <- '/projectnb/cheas/paleon/met_regional/phase1b_met_regional/corr_precipf/'
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
beg.yr  <- 850
end.yr  <- 2010
  
for(y in beg.yr:end.yr){
  
  for(m in 1:12){
    
    #open down-scaled 6-hourly mean precip file for each month
    year.now  <-sprintf('%4.4i',y)
    month.now <- sprintf('%2.2i',m)
    nc.file <- open.ncdf(paste(basedir,'precipf_',
                               year.now,'_',month.now,'.nc',sep=''))
    data <- get.var.ncdf(nc.file,'precipf')
    time <- get.var.ncdf(nc.file,'time')
    lat  <- get.var.ncdf(nc.file,'lat')
    lon  <- get.var.ncdf(nc.file,'lon')
    close.ncdf(nc.file)
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
    
    if(!is.na(dat.yr[lon.ind,lat.ind,1])){ #only if point has data
      
      #find closest NADP station by latlon great circle distance
      dist <- gdist(lat.1=nd.site.info$latitude,lon.1=nd.site.info$longitude,lat.2=ll.grid[p,2],lon.2=ll.grid[p,1])
      near.file <- nd.site.info[which(dist==min(dist)),1]
      nd.near   <- read.csv(paste(nd.path,'allsites/',nd.files[grep(near.file,nd.files)],sep=''),
                            header=TRUE,skip=3,stringsAsFactors=FALSE)
      nd.near <- nd.near[2:nrow(nd.near),] #skip blank line between header and data
      nd.near[nd.near==-9 | nd.near==-7] <- NA #replace NADP data NA and 'trace' values
      
      #parse dates
      nd.year <- nd.mon <- nd.day <- nd.doy <- vector()
      for(d in 1:nrow(nd.near)){
        yr.tmp <- strsplit(strsplit(nd.near$EndTime[d],' ')[[1]][1],'/')[[1]][3]
        nd.year[d] <- as.numeric(if(yr.tmp<20){paste('20',yr.tmp,sep='')}else{paste('19',yr.tmp,sep='')})
        nd.mon[d] <- as.numeric(strsplit(strsplit(nd.near$EndTime[d],' ')[[1]][1],'/')[[1]][1])
        nd.day[d] <- as.numeric(strsplit(strsplit(nd.near$EndTime[d],' ')[[1]][1],'/')[[1]][2])
        
        nd.doy[d] <- julian(nd.mon[d],nd.day[d],nd.year[d],origin=c(month=1,day=1,year=nd.year[d]))+1
      }
      nd.near <- cbind(nd.near,nd.year,nd.doy)
      
      #calculate mean annual precip frequency distribution from NADP site
      nd.yrs <- unique(floor(nd.year))
      for(y in nd.yrs){
        yr.dat <- nd.near[which(floor(nd.year)==y),]
        yr.ppt <- tapply(yr.dat$Amount, yr.dat$nd.doy, sum)
        
        p.break <- seq(0,1000,by=1.0)
        x.nd <- hist(yr.ppt[yr.ppt>0]*inch2mm,breaks=p.break,plot=FALSE)
        
        if(y==min(nd.yrs)){
          nd.agg <- as.vector(x.nd$density)
        } else{
          nd.agg <- apply(cbind(nd.agg,as.vector(x.nd$density)),1,mean,na.rm=TRUE)
        } 
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
          if(x.pl$density[x.ind] > nd.agg[x.ind]){
            samp.prob <- 1 - nd.agg[x.ind]/x.pl$density[x.ind] 
          } else if(x.pl$density[x.ind] < nd.agg[x.ind]){ 
            samp.prob <- 1 - x.pl$density[x.ind]/nd.agg[x.ind]
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
    nc.file   <- open.ncdf(paste(basedir,'precipf_',
                                 year.now,'_',month.now,'.nc',sep=''))
    data <- get.var.ncdf(nc.file,'precipf')
    lat <- get.var.ncdf(nc.file,'lat')
    lon <- get.var.ncdf(nc.file,'lon')
    nc.time <- get.var.ncdf(nc.file,'time')
    close.ncdf(nc.file)
    
    nc_time_units <- paste('days since 0850-01-01 00:00:00', sep='')
    time          <- dim.def.ncdf('time',nc_time_units,nc.time,unlim=TRUE)
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
    dimY <- dim.def.ncdf( 'lat', 'latitude: degrees', lat )
    dimX <- dim.def.ncdf( 'lon', 'longitude: degrees', lon )
    dimT <- dim.def.ncdf( 'time',nc_time_units, time)
    
    nc_var  <- var.def.ncdf('precipf',nc_variable_units,
                            list(dimX,dimY,time), fillv, longname=nc_variable_long_name,prec='double')
    
    ofname  <- paste(outpath,'precipf_',sprintf('%04i',y),'_',
                     sprintf('%02i',m),'.nc',sep='')
    newfile <- create.ncdf(ofname, nc_var) # Initialize file 
    
    att.put.ncdf( newfile, time, 'calendar', 'days since 850')
    att.put.ncdf( newfile, 0, 'description','PalEON formatted Phase 1 met driver')
    
    put.var.ncdf(newfile, nc_var, data.new) # Write netCDF file
    
    close.ncdf(newfile)  
    
  }
}




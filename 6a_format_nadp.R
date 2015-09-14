#Format and export the site-level NADP data for PalEON precipitation distribution adjustment 
#to save time in the processing code (fix_precip_regional.R)
#Original: Jaclyn Hatala Matthes, 12 June 2014, jaclyn.hatala.matthes@gmail.com
#Edits: Christy Rollinson, January 2015, crollinson@gmail.com

library(ncdf4)
library(date)
library(chron)
library(abind)

#Calculates the geodesic distance between two points specified by radian latitude/longitude using the
#Spherical Law of Cosines (slc)
gcd.slc <- function(long1, lat1, long2, lat2) {
  R <- 6371 # Earth mean radius [km]
  d <- acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2) * cos(long2-long1)) * R
  return(d) # Distance in km
}

#Convert lat/lon degrees to radians
deg2rad <- function(deg) return(deg*pi/180)

#Constants
inch2mm <- 2.54*10
p.break <- seq(0,1000,by=1.0)

#NADP data to get precip distribution
nd.path    <- '/projectnb/dietzelab/paleon/met_regional/fix_precip/nadp/'
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

#open 1 file to get lat, lon grid for PalEON
basedir <- '/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp_v2/precipf/'
nc.file <- nc_open(paste(basedir,'precipf_0850_01.nc',sep=''))
data <- ncvar_get(nc.file,'precipf')
time <- ncvar_get(nc.file,'time')
lat  <- ncvar_get(nc.file,'lat')
lon  <- ncvar_get(nc.file,'lon')
nc_close(nc.file)
ll.grid <- expand.grid(lon,lat)

#find nearest NADP station for each grid point
nearest.nadp <- vector()
for(p in 1:nrow(ll.grid)){
  dist <- gcd.slc(deg2rad(nd.site.info$longitude),deg2rad(nd.site.info$latitude),deg2rad(ll.grid[p,1]),deg2rad(ll.grid[p,2]))
  nearest.nadp[p] <- nd.site.info[which(dist==min(dist)),1]
}

#format NADP data
nd.daily <- list()
for(f in 1:length(nd.files)){
  nd.near   <- read.csv(paste(nd.path,'allsites/',nd.files[f],sep=''),
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
    yr.ppt <- tapply(yr.dat$Amount, yr.dat$nd.doy, sum, na.rm=T)
    
    p.break <- seq(0,1000,by=1.0)
    x.nd <- hist(yr.ppt[yr.ppt>0]*inch2mm,breaks=p.break,plot=FALSE)
    
    if(y==min(nd.yrs)){
      nd.agg <- as.vector(x.nd$density)
    } else{
      nd.agg <- apply(cbind(nd.agg,as.vector(x.nd$density)),1,mean,na.rm=TRUE)
    } 
  }
  nd.daily[[f]] <- nd.agg
}

save(nd.daily,nearest.nadp,nd.sites,nd.site.info,file='/projectnb/dietzelab/paleon/met_regional/fix_precip/NADP_daily.Rdata')




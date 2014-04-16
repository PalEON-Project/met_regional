#Eliminate small values in the neural network output for precipitation.
#1. Find daily rainfall distribution based on nearest NADP sites.
#2. Test distribution of PalEON daily rainfall against NADP rainfall.
#3. Aggregate too-low precip by probability based on difference b/w data and model distributions.
#Jaclyn Hatala Matthes, 4/10/14

library(ncdf,lib.loc="/usr4/spclpgm/jmatthes/")

#NADP data to get precip distribution
nd.path    <- "/projectnb/cheas/paleon/met_regional/fix_precip/nadp/"
nd.files   <- list.files(nd.path)
pl.sites   <- c("PHA","PHO","PMB","PUN","PBL","PDL")
nd.sites   <- c("MA08","ME09","MI09","WI36","MN16","MN16")

#PALEON down-scaled 6-hourly precipitation
basedir <- "/projectnb/cheas/paleon/met_regional/phase1a_met_drivers_v2/"
outpath <- "/projectnb/cheas/paleon/met_regional/phase1a_met_drivers_v2/precipf_corr/"
beg.yr <- 850
end.yr <- 2010
n.samps <- 1000

#constants
dpm   <- c(1,31,28,31,30,31,30,31,31,30,31,30,31) #days per month
dpm.l <- c(1,31,29,31,30,31,30,31,31,30,31,30,31) #leap year days per month
inch2mm <- 2.54*10
day2sec <- 1/(24*60*60)
sec26hr <- 60*60*6
fillv   <- 1e+30

for(s in 1:length(pl.sites)){
  
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




# #FIRST USE AMERIFLUX DATA TO LOOK FOR MIN PRECIP VALUE
# af.path <- "/projectnb/cheas/paleon/met_regional/fix_precip/ameriflux/"
# af.file <- list.files(af.path)
# sites   <- c("Ha1","Ho1","UMB")
# window.avg <- 24
# 
# min.6hr <- max.6hr <- med.6hr <- low.6hr <- list()
# for(f in 1:length(af.file)){
#   dat <- read.csv(paste(af.path,af.file[f],sep=""),header=TRUE)
#   dat[dat==-9999] <- NA
#   
#   #   #figure out if data are hourly/half-hourly
#   #   time.check <- diff(dat[dat[,1]>=2007 & dat[,1]<2008,1])*365
#   #   if(time.check[1]*24>0.9){ #if hourly
#   #     time.stat <- 1
#   #   } else if(time.check[1]*24<0.9){ #if half-hourly
#   #     time.stat <- 2
#   #   } else{
#   #     print("Warning! Ameriflux time is weird.")
#   #   }
#   #   
#   #calculate annual precip distirbution
#   af.yrs <- unique(floor(dat[,1]))
#   min.6hr[[f]] <- max.6hr[[f]] <- low.6hr[[f]] <- med.6hr[[f]] <- vector(length=length(af.yrs))
#   for(y in af.yrs){
#     yr.dat <- dat[which(floor(dat[,1])==y),2]
#     
#     if(length(yr.dat)>1){
#       #mean 6-hourly precip: mm/(time.stat) = mm/hr --> mm/s
#       yr.6hr <- tapply(yr.dat/(time.stat), (seq_along(yr.dat)-1) %/% (window.avg*time.stat), sum)/(window.avg*60*60)
#       
#       print(paste("Summer: ",mean(yr.6hr[200:300][which(yr.6hr[200:300]>0)],na.rm=TRUE),sep=""))
#       print(paste("Winter: ",mean(yr.6hr[1:100][which(yr.6hr[1:100]>0)],na.rm=TRUE),sep=""))
#       
#       if(sum(!is.na(yr.6hr))>1){
#         hist(yr.6hr[yr.6hr>0]*(60*60*window.avg),main=paste(sites[f],": ",y,sep=""),
#              xlab="Precip [mm/6hr]",ylab="density",breaks=c(seq(0,20,by=0.5),
#                                                             max(yr.6hr[yr.6hr>0]*(60*60*window.avg),na.rm=TRUE)),xlim=c(0,100))
#       }
#       min.6hr[[f]][y-min(af.yrs)+1] <- min(yr.6hr[yr.6hr>0],na.rm=TRUE)
#       max.6hr[[f]][y-min(af.yrs)+1] <- max(yr.6hr[yr.6hr>0],na.rm=TRUE)
#       med.6hr[[f]][y-min(af.yrs)+1] <- median(yr.6hr[yr.6hr>0],na.rm=TRUE)
#       low.6hr[[f]][y-min(af.yrs)+1] <- quantile(yr.6hr[yr.6hr>0], 0.05, na.rm = TRUE)
#       
#     } else{
#       min.6hr[[f]][y-min(af.yrs)+1] <- NA
#       max.6hr[[f]][y-min(af.yrs)+1] <- NA
#       med.6hr[[f]][y-min(af.yrs)+1] <- NA
#       low.6hr[[f]][y-min(af.yrs)+1] <- NA
#     }
#   }
# }
# 

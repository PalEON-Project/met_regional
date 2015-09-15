# ----------------------------------------------
# Script to do some QA/QC on the regional (Phase 2) PalEON met Driver Data
# Christine Rollinson, crollinson@gmail.com
# Original: 14 September, 2015
#
# --------------
# QA/QC Checks
# --------------
# Region-Level:
# Note: This set will probably use parallel processing to: 
#       1) speed things up; 
#       2) provide an example of raster parallelzation in R for others to use
# A) Animated Maps (upload to web)
#    1) Monthly Means -- Entire PalEON Temporal & Spatial Domain
#    2) Diurnal Cycle -- 1 year (mean of tempororal domain?)
# B) Static Maps (for QA/QC document)
#    1) Annual Means  -- spinup (1850-1869); modern climate (1980-2010)
#    3) Monthly Means -- mean of entire temporal domain
# 
# Random Site Checks (10? random points)
# 1) 6-hrly, full time range
# 2) Monthly means, full time range
# 3) Annual means, full time range
# --------------
#
# ----------------------------------------------


# ----------------------------------------------
# Load libaries, Set up Directories, etc
# ----------------------------------------------
library(raster); library(animation)
library(ncdf4); library(ggplot2); library(grid)
dir.met  <- "/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp_v2/"
dir.out  <- "/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp_v2/met_qaqc"

if(!dir.exists(dir.out)) dir.create(dir.out)

# Variables we're graphing
# vars         <- c("tair", "precipf_corr", "swdown", "lwdown", "qair", "psurf", "wind") 
vars         <- c("tair", "precipf", "swdown", "lwdown", "qair", "psurf", "wind") 

# window for graphing monthly means
yr.start.mo  <- 1800
yr.end.mo    <- 2010

# window for graphing daily pattern
yr.start.day1 <- 0850
yr.end.day1   <- 0850
# yr.start.day2 <- 2010
# yr.end.day2   <- 2010

# ranges.month  <- data.frame(var=vars, Min=c(240,0,100,0,0,0,90000,0), Max=(330,250,500,4000,0.025,0,102000,15))
ranges.month  <- data.frame(var=vars, Min=c(240,0,100,0,0,90000,0), Max=c(330,250,600,5000,0.025,110000,35))
ranges.day    <- data.frame(var=vars, Min=c(240,0,0,0,0,90000,0), Max=c(330,250,1000,5000,0.025,110000,35))
paleon.states <- map_data("state")


# ----------------------------------------------


# ----------------------------------------------
# Read in & graph by variable
# ----------------------------------------------
# v="tair"
for(v in vars){
	# Definining our file paths
	dir.var <- file.path(dir.met, v)	
	var.files <- dir(dir.var)
	nchar.v <- nchar(v)
	
	# ---------------------
	# Working 1 file at a time to calculating and graph the monthly mean
	# ---------------------
	# Getting just the years for the time frame we're interested in
	files.graph <-	var.files[which(as.numeric(substr(var.files, nchar.v+2,nchar.v+5))>=yr.start.mo & as.numeric(substr(var.files, nchar.v+2,nchar.v+5))<=yr.end.mo)]


	saveGIF( {  for(i in 1:length(files.graph)){
	print(paste0("---- ", files.graph[i], " ----"))
	ncT <- stack(file.path(dir.var, files.graph[i]))

    tmp  <- strsplit(files.graph[i],"_")
    year <- tmp[[1]][2]
    mon  <- substring(tmp[[1]][3],1,2)
	# ncT
	# summary(ncT)
	# class(ncT)
	# names(ncT)
	# dim(ncT)

	ncT.x1 <- mean(ncT)
	ncT.x <- data.frame(rasterToPoints(ncT.x1))
	# ncTx.pt <- data.frame(rasterToPoints(test))
	names(ncT.x) <- c("lon", "lat", "tair")
	# summary(test.pt)
	
	# plot(test)

	print(
	ggplot(data=ncT.x) +
		geom_raster(aes(x=lon, y=lat, fill=tair)) +
		scale_fill_gradientn(colours=c("blue", "red"), limits=c(ranges.month[ranges.month$var==v,"Min"], ranges.month[ranges.month$var==v,"Max"])) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(ncT.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(ncT.x$lat), expand=c(0,0), name="Latitude") +
		ggtitle(paste(year, mon, sep=" - ")) +
		# borders("state") +
		coord_equal(ratio=1))}}, movie.name=file.path(dir.out, paste0(v, "_MonthMean", "_", yr.start.mo, "-", yr.end.mo, ".gif")), interval=0.3, nmax=10000, autobrowse=F, autoplay=F)
	# ---------------------

	# ---------------------
	# Working 1 file at a time to graph the raw sub-daily drivers
	# ---------------------
	# Getting just the years for the time frame we're interested in
	files.graph <-	var.files[which(as.numeric(substr(var.files, nchar.v+2,nchar.v+5))>=yr.start.day1 & as.numeric(substr(var.files, nchar.v+2,nchar.v+5))<=yr.end.day1)]


	saveGIF( {  for(i in 1:length(files.graph)){
	print(paste0("---- ", files.graph[i], " ----"))
	ncT <- stack(file.path(dir.var, files.graph[i]))

	for(y in 1:nlayers(ncT)){
		ncT.x <- data.frame(rasterToPoints(ncT[[y]]))
		# ncTx.pt <- data.frame(rasterToPoints(test))
		names(ncT.x) <- c("lon", "lat", "tair")

	    tmp  <- strsplit(names(ncT)[y],"[.]")
	    year <- substr(tmp[[1]][1],2,5)
	    mon  <- tmp[[1]][2]
	    day  <- tmp[[1]][3]
	    hr   <- (as.numeric(tmp[[1]][4])-1)*6

	 	print(
	ggplot(data=ncT.x) +
		geom_raster(aes(x=lon, y=lat, fill=tair)) +
		scale_fill_gradientn(colours=c("blue", "red"), limits=c(ranges.day[ranges.day$var==v,"Min"], ranges.day[ranges.day$var==v,"Max"])) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(ncT.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(ncT.x$lat), expand=c(0,0), name="Latitude") +
		ggtitle(paste(year, mon, day, hr, sep=" - ")) +
		# borders("state") +
		coord_equal(ratio=1))	
	}
	}}, movie.name=file.path(dir.out, paste0(v, "_SubDailyRaw", "_", yr.start.day1, "-", yr.end.day1, ".gif")), interval=0.25, nmax=10000, autobrowse=F, autoplay=F)

	# # Doing a second year daily slice just for good measure
	# # Getting just the years for the time frame we're interested in
	# files.graph <-	var.files[which(as.numeric(substr(var.files, nchar.v+2,nchar.v+5))>=yr.start.day2 & as.numeric(substr(var.files, nchar.v+2,nchar.v+5))<=yr.end.day2)]


	# saveGIF( {  for(i in 1:length(files.graph)){
	# print(paste0("---- ", files.graph[i], " ----"))
	# ncT <- stack(file.path(dir.var, files.graph[i]))

	# for(y in 1:nlayers(ncT)){
		# ncT.x <- data.frame(rasterToPoints(ncT[[y]]))
		# # ncTx.pt <- data.frame(rasterToPoints(test))
		# names(ncT.x) <- c("lon", "lat", "tair")

	    # tmp  <- strsplit(names(ncT)[y],"[.]")
	    # year <- substr(tmp[[1]][1],2,5)
	    # mon  <- tmp[[1]][2]
	    # day  <- tmp[[1]][3]
	    # hr   <- (as.numeric(tmp[[1]][4])-1)*6

	 	# print(
	# ggplot(data=ncT.x) +
		# geom_raster(aes(x=lon, y=lat, fill=tair)) +
		# scale_fill_gradientn(colours=c("blue", "red"), limits=c(ranges.day[ranges.day$var==v,"Min"], ranges.day[ranges.day$var==v,"Max"])) +
		# geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		# scale_x_continuous(limits=range(ncT.x$lon), expand=c(0,0), name="Longitude") +
		# scale_y_continuous(limits=range(ncT.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste(year, mon, day, hr, sep=" - ")) +
		# # borders("state") +
		# coord_equal(ratio=1))	
	# }
	# }}, movie.name=file.path(dir.out, paste0(v, "_SubDailyRaw", "_", yr.start.day2, "-", yr.end.day2, ".gif")), interval=0.25, nmax=10000, autobrowse=F, autoplay=F)
 	# ---------------------

}

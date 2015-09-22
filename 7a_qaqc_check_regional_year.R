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
# dir.met  <- "/projectnb/dietzelab/paleon/met_regional/bias_corr/final_output_v2/"
# dir.met <- "~/Dropbox/PalEON CR/met_regional/met_examples"
dir.out  <- "/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp_v2/met_qaqc"
# dir.out  <- "/projectnb/dietzelab/paleon/met_regional/bias_corr/final_output_v2/met_qaqc"
# dir.out <- "~/Dropbox/PalEON CR/met_regional/met_qaqc"
if(!dir.exists(dir.out)) dir.create(dir.out)

# Variables we're graphing
# vars         <- c("tair", "precipf_corr", "swdown", "lwdown", "qair", "psurf", "wind") 
vars         <- c("tair", "precipf_corr", "swdown", "lwdown", "qair", "psurf", "wind") 

# Window for full annual means
yr.start1  <- 1850
yr.end1    <- 2010


# window for graphing monthly means
# Note: 2 windows to get each of the splice points
# yr.start.mo1  <- 1849
yr.start.mo1  <- 1849
yr.end.mo1    <- 1850

yr.start.mo2  <- 1900
yr.end.mo2    <- 1901

# window for graphing daily pattern
# Note: 3 to get each of the 3 datasets spliced in
yr.start.day1 <- 0850
yr.start.day2 <- 1900
yr.start.day3 <- 1950

# ranges.month  <- data.frame(var=vars, Min=c(240,0,100,0,0,0,90000,0), Max=(330,250,500,4000,0.025,0,102000,15))
ranges.month  <- data.frame(var=vars, Min=c(240,0,100,0,0,90000,0), Max=c(330,1e-4,600,5000,0.025,110000,35))
ranges.day    <- data.frame(var=vars, Min=c(240,0,0,0,0,90000,0), Max=c(330,250,1000,5000,0.025,110000,35))
paleon.states <- map_data("state")


# ----------------------------------------------


# ----------------------------------------------
# Read in & graph by variable
# ----------------------------------------------
# v="tair"

files.tair     <- dir(file.path(dir.met, "tair"))
files.precipf  <- dir(file.path(dir.met, "precipf_corr"))
files.swdown   <- dir(file.path(dir.met, "swdown"))
files.lwdown   <- dir(file.path(dir.met, "lwdown"))
files.qair     <- dir(file.path(dir.met, "qair"))
files.psurf    <- dir(file.path(dir.met, "psurf"))
files.wind     <- dir(file.path(dir.met, "wind"))
# for(v in vars){
	# # Definining our file paths
	# dir.var <- file.path(dir.met, v)	
	# var.files <- dir(dir.var)
	# nchar.v <- nchar(v)


# ---------------------
# Saving Full Annual Means
# ---------------------
# Getting just the years for the time frame we're interested in

saveGIF( {  
  # Looping through each file to generate the image for each step of the animation
  for(y in yr.start1:yr.end1){
  tair.graph    <-	files.tair   [which(as.numeric(substr(files.tair,    6,9))==y)]
  precipf.graph <-	files.precipf[which(as.numeric(substr(files.precipf, 9,12))==y)]
  swdown.graph  <-	files.swdown [which(as.numeric(substr(files.swdown,  8,11))==y)]
  lwdown.graph  <-	files.lwdown [which(as.numeric(substr(files.lwdown,  8,11))==y)]
  qair.graph    <-	files.qair   [which(as.numeric(substr(files.qair,    6,9))==y)]
  psurf.graph   <-	files.psurf  [which(as.numeric(substr(files.psurf,   7,10))==y)]
  wind.graph    <-	files.wind   [which(as.numeric(substr(files.wind,    6,9))==y)]

  for(i in 1:length(tair.graph)){
	print(paste0("---- ", tair.graph[i], " ----"))
	# Doing all the variables here because we're going to plot them all together on the giff
	tair.full    <- stack(file.path(dir.met, "tair",    tair.graph[i]))
	precipf.full <- stack(file.path(dir.met, "precipf_corr", precipf.graph[i]))
	swdown.full  <- stack(file.path(dir.met, "swdown",  swdown.graph[i]))
	lwdown.full  <- stack(file.path(dir.met, "lwdown",  lwdown.graph[i]))
	qair.full    <- stack(file.path(dir.met, "qair",    qair.graph[i]))
	psurf.full   <- stack(file.path(dir.met, "psurf",   psurf.graph[i]))
	wind.full    <- stack(file.path(dir.met, "wind",    wind.graph[i]))

    tmp  <- strsplit(tair.graph[i],"_")
    year <- tmp[[1]][2]
    mon  <- substring(tmp[[1]][3],1,2)

	# Finding the monthly mean for each time step 
	# (for some reason this doesn't work well combined with the next step)
	tair.x1    <- mean(tair.full)
	precipf.x1 <- mean(precipf.full)
	swdown.x1  <- mean(swdown.full)
	lwdown.x1  <- mean(lwdown.full)
	qair.x1    <- mean(qair.full)
	psurf.x1   <- mean(psurf.full)
	wind.x1    <- mean(wind.full)

	if(i == 1){
	tair.x2    <- data.frame(rasterToPoints(tair.x1))
	precipf.x2 <- data.frame(rasterToPoints(precipf.x1))
	swdown.x2  <- data.frame(rasterToPoints(swdown.x1))
	lwdown.x2  <- data.frame(rasterToPoints(lwdown.x1))
	qair.x2    <- data.frame(rasterToPoints(qair.x1))
	psurf.x2   <- data.frame(rasterToPoints(psurf.x1))
	wind.x2    <- data.frame(rasterToPoints(wind.x1))
	names(tair.x2)    <- c("lon", "lat", "tair")
	names(precipf.x2) <- c("lon", "lat", "precipf")
	names(swdown.x2)  <- c("lon", "lat", "swdown")
	names(lwdown.x2)  <- c("lon", "lat", "lwdown")
	names(qair.x2)    <- c("lon", "lat", "qair")
	names(psurf.x2)   <- c("lon", "lat", "psurf")
	names(wind.x2)    <- c("lon", "lat", "wind")
	} else {
	tair.x2   [,i+2] <- rasterToPoints(tair.x1   )[,3]
	precipf.x2[,i+2] <- rasterToPoints(precipf.x1)[,3]
	swdown.x2 [,i+2] <- rasterToPoints(swdown.x1 )[,3]
	lwdown.x2 [,i+2] <- rasterToPoints(lwdown.x1 )[,3]
	qair.x2   [,i+2] <- rasterToPoints(qair.x1   )[,3]
	psurf.x2  [,i+2] <- rasterToPoints(psurf.x1  )[,3]
	wind.x2   [,i+2] <- rasterToPoints(wind.x1   )[,3]
	}
	} # end file loop
	
	# finding the annual means
	tair.x    <- data.frame(tair.x2   [,1:2], tair   =rowMeans(tair.x2   [,3:ncol(tair.x2   )]))
	precipf.x <- data.frame(precipf.x2[,1:2], precipf=rowMeans(precipf.x2[,3:ncol(precipf.x2)]))
	swdown.x  <- data.frame(swdown.x2 [,1:2], swdown =rowMeans(swdown.x2 [,3:ncol(swdown.x2 )]))
	lwdown.x  <- data.frame(lwdown.x2 [,1:2], lwdown =rowMeans(lwdown.x2 [,3:ncol(lwdown.x2 )]))
	qair.x    <- data.frame(qair.x2   [,1:2], qair   =rowMeans(qair.x2   [,3:ncol(qair.x2   )]))
	psurf.x   <- data.frame(psurf.x2  [,1:2], psurf  =rowMeans(psurf.x2  [,3:ncol(psurf.x2  )]))
	wind.x    <- data.frame(wind.x2   [,1:2], wind   =rowMeans(wind.x2   [,3:ncol(wind.x2   )]))


	plot.tair <- ggplot(data=tair.x) +
		geom_raster(aes(x=lon, y=lat, fill=tair)) +
		scale_fill_gradientn(colours=c("gray50", "red3"), limits=c(270,300)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(tair.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(tair.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position="bottom", 
              # legend.direction="horizontal") +
        theme(panel.background=element_blank(), 
              axis.title.y=element_blank(),
              axis.title.x=element_blank()) +
		coord_equal(ratio=1)

	plot.precipf <- ggplot(data=precipf.x) +
		geom_raster(aes(x=lon, y=lat, fill=precipf)) +
		scale_fill_gradientn(colours=c("gray50", "blue3"), limits=c(0,1.5e-4)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(precipf.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(precipf.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Precipf", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)

	plot.swdown <- ggplot(data=swdown.x) +
		geom_raster(aes(x=lon, y=lat, fill=swdown)) +
		scale_fill_gradientn(colours=c("gray50", "goldenrod2"), limits=c(150,250)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(swdown.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(swdown.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)

	plot.lwdown <- ggplot(data=lwdown.x) +
		geom_raster(aes(x=lon, y=lat, fill=lwdown)) +
		# scale_fill_gradientn(colours=c("gray50", "darkorange1"), limits=c(0,330)) +
		scale_fill_gradientn(colours=c("gray50", "darkorange1"), limits=c(200,400)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(lwdown.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(lwdown.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)

	plot.qair <- ggplot(data=qair.x) +
		geom_raster(aes(x=lon, y=lat, fill=qair)) +
		scale_fill_gradientn(colours=c("gray50", "aquamarine3"), limits=c(0.0028, 0.01)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(qair.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(qair.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)

	plot.psurf <- ggplot(data=psurf.x) +
		geom_raster(aes(x=lon, y=lat, fill=psurf)) +
		scale_fill_gradientn(colours=c("gray50", "mediumpurple2"), limits=c(91000,110000)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(psurf.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(psurf.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)
		
	plot.wind <- ggplot(data=wind.x) +
		geom_raster(aes(x=lon, y=lat, fill=wind)) +
		scale_fill_gradientn(colours=c("gray80", "gray30"), limits=c(0,10)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(wind.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(wind.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)
		
	plot.time <- ggplot(data=tair.x) +
		geom_text(aes(x=1, y=1, label=paste0(year)), size=24) +
        theme(panel.background=element_blank()) 


	# Setting up a grid layout to graph all variables at once
	grid.newpage()
	pushViewport(viewport(layout=grid.layout(4,2)))
	print(plot.tair,    vp = viewport(layout.pos.row = 1, layout.pos.col = 1))
	print(plot.precipf, vp = viewport(layout.pos.row = 1, layout.pos.col = 2))
	print(plot.swdown,  vp = viewport(layout.pos.row = 2, layout.pos.col = 1))
	print(plot.lwdown,  vp = viewport(layout.pos.row = 2, layout.pos.col = 2))
	print(plot.qair,    vp = viewport(layout.pos.row = 3, layout.pos.col = 1))
	print(plot.psurf,   vp = viewport(layout.pos.row = 3, layout.pos.col = 2))
	print(plot.wind,    vp = viewport(layout.pos.row = 4, layout.pos.col = 1))
	print(plot.time,    vp = viewport(layout.pos.row = 4, layout.pos.col = 2))

	rm(tair.x, tair.x2, precipf.x, precipf.x2, swdown.x, swdown.x2, lwdown, lwdown.x2, qair.x, qair.x2, psurf.x, psurf.x2, wind.x, wind.x2)
	}
	},	movie.name=file.path(dir.out, paste0("MetDrivers_YearMeans", "_", yr.start1, "-", yr.end1, ".gif")), interval=0.3, nmax=10000, autobrowse=F, autoplay=F, ani.height=800, ani.width=800)
# ---------------------

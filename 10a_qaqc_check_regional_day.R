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
dir.met  <- "/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2_daily/"
dir.out  <- "/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2_daily/met_qaqc"
if(!dir.exists(dir.out)) dir.create(dir.out)

# Variables we're graphing
vars         <- c("tair", "precipf", "swdown", "lwdown", "qair", "psurf", "wind") 


yr.start.day1 <- 1250

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
files.precipf  <- dir(file.path(dir.met, "precipf"))
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
# Saving Monthly: Daily Snapshot 1 (April)
# ---------------------
# Getting just the years for the time frame we're interested in
files.graph <-	which(as.numeric(substr(files.tair, 6,9))==yr.start.day1 & as.numeric(substr(files.tair, 11,12))==4)

saveGIF( {  
  # Looping through each file to generate the image for each step of the animation
  for(i in files.graph){
	print(paste0("---- ", files.tair[i], " ----"))
	# Doing all the variables here because we're going to plot them all together on the giff
	tair.full    <- stack(file.path(dir.met, "tair",    files.tair[i]))
	precipf.full <- stack(file.path(dir.met, "precipf", files.precipf[i]))
	swdown.full  <- stack(file.path(dir.met, "swdown",  files.swdown[i]))
	lwdown.full  <- stack(file.path(dir.met, "lwdown",  files.lwdown[i]))
	qair.full    <- stack(file.path(dir.met, "qair",    files.qair[i]))
	psurf.full   <- stack(file.path(dir.met, "psurf",   files.psurf[i]))
	wind.full    <- stack(file.path(dir.met, "wind",    files.wind[i]))

	for(y in 1:nlayers(tair.full)){
	tair.x    <- data.frame(rasterToPoints(tair.full[[y]]))
	precipf.x <- data.frame(rasterToPoints(precipf.full[[y]]))
	swdown.x  <- data.frame(rasterToPoints(swdown.full[[y]]))
	lwdown.x  <- data.frame(rasterToPoints(lwdown.full[[y]]))
	qair.x    <- data.frame(rasterToPoints(qair.full[[y]]))
	psurf.x   <- data.frame(rasterToPoints(psurf.full[[y]]))
	wind.x    <- data.frame(rasterToPoints(wind.full[[y]]))		
	names(tair.x)    <- c("lon", "lat", "tair")
	names(precipf.x) <- c("lon", "lat", "precipf")
	names(swdown.x)  <- c("lon", "lat", "swdown")
	names(lwdown.x)  <- c("lon", "lat", "lwdown")
	names(qair.x)    <- c("lon", "lat", "qair")
	names(psurf.x)   <- c("lon", "lat", "psurf")
	names(wind.x)    <- c("lon", "lat", "wind")

    tmp  <- strsplit(names(tair.full)[y],"[.]")
    year <- tmp[[1]][1]
    mon  <- tmp[[1]][2]
	day  <- tmp[[1]][3]
	hr   <- (as.numeric(tmp[[1]][4])-1)*6
		
	plot.tair <- ggplot(data=tair.x) +
		geom_raster(aes(x=lon, y=lat, fill=tair)) +
		scale_fill_gradientn(colours=c("gray50", "red3"), limits=c(240,330)) +
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
		scale_fill_gradientn(colours=c("gray50", "blue3"), limits=c(0,2.25e-3)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(tair.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(tair.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Precipf", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)
	plot.swdown <- ggplot(data=swdown.x) +
		geom_raster(aes(x=lon, y=lat, fill=swdown)) +
		scale_fill_gradientn(colours=c("gray50", "goldenrod2"), limits=c(0,750)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(tair.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(tair.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)
	plot.lwdown <- ggplot(data=lwdown.x) +
		geom_raster(aes(x=lon, y=lat, fill=lwdown)) +
		# scale_fill_gradientn(colours=c("gray50", "darkorange1"), limits=c(0,330)) +
		scale_fill_gradientn(colours=c("gray50", "darkorange1"), limits=c(0,1000)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(tair.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(tair.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)
	plot.qair <- ggplot(data=qair.x) +
		geom_raster(aes(x=lon, y=lat, fill=qair)) +
		scale_fill_gradientn(colours=c("gray50", "aquamarine3"), limits=c(0, 0.025)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(tair.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(tair.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)
	plot.psurf <- ggplot(data=psurf.x) +
		geom_raster(aes(x=lon, y=lat, fill=psurf)) +
		scale_fill_gradientn(colours=c("gray50", "mediumpurple2"), limits=c(90000,110000)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(tair.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(tair.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)
	plot.wind <- ggplot(data=wind.x) +
		geom_raster(aes(x=lon, y=lat, fill=wind)) +
		scale_fill_gradientn(colours=c("gray80", "gray30"), limits=c(0,35)) +
		geom_path(data=paleon.states, aes(x=long, y=lat, group=group)) +
		scale_x_continuous(limits=range(tair.x$lon), expand=c(0,0), name="Longitude") +
		scale_y_continuous(limits=range(tair.x$lat), expand=c(0,0), name="Latitude") +
		# ggtitle(paste("Tair", year, mon, sep=" - ")) +
        theme(plot.margin=unit(c(0,0,0,0), "lines")) +
        # theme(legend.position=c(0.75, 0.1), legend.direction="horizontal") +
        theme(panel.background=element_blank()) +
		coord_equal(ratio=1)
	plot.time <- ggplot(data=tair.x) +
		geom_text(aes(x=1, y=1, label=paste(year, mon, day, sep=" - ")), size=14) +
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
	}
	}
	}, movie.name=file.path(dir.out, paste0("MetDrivers_6hrlyData", "_", yr.start.day1, "-04.gif")), interval=0.3, nmax=10000, autobrowse=F, autoplay=F, ani.height=800, ani.width=800)
# ---------------------



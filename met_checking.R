# Met Checking: Check Met Bias corrections to make sure we smoothed over splices
# Christy Rollinson, January 2015, crollinson@gmail.com

library(ncdf4)
sites <- c("PHA", "PHO", "PUN", "PBL", "PDL", "PMB")
vars <- c("lwdown", "precipf", "psurf", "qair", "swdown", "tair", "wind")
dir <- "/projectnb/dietzelab/paleon/met_regional/phase1a_met_drivers_v4.2"
figdir <- "/projectnb/dietzelab/paleon/met_regional/phase1a_met_drivers_v4.2/Met_Check_Figures"

for(s in unique(sites)){
	paste0("---------- ", s, " ----------")
	for(v in unique(vars)){
		paste0(v)	
		flist <- dir(file.path(dir, s, v))
		temp <- vector()
		# get monthly means
		for(i in 1:length(flist)){
			nc <- nc_open(file.path(dir, s, v, flist[i]))
			if(v == "precipf_corr"){
			temp <- c(temp, mean(ncvar_get(nc, "precipf")))				
			} else {
			temp <- c(temp, mean(ncvar_get(nc, v))) }
			nc_close(nc)
		}
		# Aggregate monthly means to annual
		mos <- seq(1, length(temp), by=12)
		temp2 <- vector()
	    for(i in 1:length(mos)){
	    		temp2 <- c(temp2, mean(temp[mos[i]:(mos[i]+11)]))
	    }
		pdf(file=paste0(figdir,"/",s,"_",v,"_yr.pdf"))	
		plot(temp2, type="l", lwd=2, xlab="Yrs since 850", ylab=v)
		dev.off()
	}
}

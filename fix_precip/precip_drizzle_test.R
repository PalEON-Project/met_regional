#look at precip stats to determine drizzle effects
#Jaclyn Hatala Matthes, 4/7/14

path <- "/projectnb/cheas/paleon/met_regional/phase1a_met_drivers_v2/PHA/precipf/"
files <- list.files(path)

for(f in 1:120){
  f.nc <- open.ncdf(paste(path,files[f],sep=""))
  tas  <- get.var.ncdf(f.nc,"precipf")
  close.ncdf(f.nc)
  
  daily.small <- sum(tas[tas*60*60*6<1]*60*60*6) #sum values less than 1mm/6hr
  daily.sum   <- tapply(tas*60*60*6, (seq_along(tas)-1) %/% 4, sum) #sum daily precip
  monthly.sum <- sum(tas*60*60*6) #sum monthly precip
  
  if(f==1){
    pr.sml <- daily.small
    pr.day <- daily.sum
    pr.mon <- monthly.sum
  } else{
    pr.sml <- c(pr.sml,daily.small)
    pr.day <- c(tas.all,daily.sum)
    pr.mon <- c(pr.mon,monthly.sum)
  } 
}

pr.ann <- tapply(pr.mon, (seq_along(pr.mon)-1) %/% 12, sum) #sum daily precip
pr.small.ann <- tapply(pr.sml, (seq_along(pr.sml)-1) %/% 12, sum) #sum daily precip
pr.bias <- pr.small.ann/pr.ann

plot(pr.small.ann/pr.ann)


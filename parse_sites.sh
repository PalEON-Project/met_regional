#!bin/bash
#This code loops through files and separates out met data for the 
#sites Harvard Forest (Ha1), Howland Forest (Ho1), and UNDERC (Und)
#Jaclyn Hatala Matthes, 1/14/14
#jaclyn.hatala.matthes@gmail.com

in_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/
out_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/sites/

vars=(psurf)

pushd ${in_dir}

for var in ${vars[@]}
do
    ncea -O -d lat,42.5,43.0 -d lon,-72.5,-72.0 ${var}_gcm_cat.nc ${out_dir}Ha1_${var}_cat.nc
    ncea -O -d lat,45.0,45.5 -d lon,-69.0,-68.5 ${var}_gcm_cat.nc ${out_dir}Ho1_${var}_cat.nc
    ncea -O -d lat,46.0,46.5 -d lon,-89.5,-89.0 ${var}_gcm_cat.nc ${out_dir}Und_${var}_cat.nc
done




#!bin/bash
#This code loops through files and separates out met data for the 
#sites Harvard Forest (Ha1), Howland Forest (Ho1), and UNDERC (Und)
#Jaclyn Hatala Matthes, 1/14/14
#jaclyn.hatala.matthes@gmail.com

in_dir=/projectnb/dietzelab/paleon/met_regional/cruncep/
out_dir=/projectnb/dietzelab/paleon/met_regional/cruncep/sites/

vars=(lwdown precipf psurf qair swdown tair wind)

for var in ${vars[@]}
do
    pushd ${in_dir}${var}/
    for file in *.nc
    do
	ncea -O -d lat,42.5,43.0 -d lon,-72.5,-72.0 $file ${out_dir}PHA/${var}/PHA_$file
	ncea -O -d lat,45.0,45.5 -d lon,-69.0,-68.5 $file ${out_dir}PHO/${var}/PHO_$file
	ncea -O -d lat,46.0,46.5 -d lon,-89.5,-89.0 $file ${out_dir}PUN/${var}/PUN_$file
	ncea -O -d lat,46.0,46.5 -d lon,-95.0,-94.5 $file ${out_dir}PBL/${var}/PBL_$file
	ncea -O -d lat,47.0,47.5 -d lon,-95.5,-95.0 $file ${out_dir}PDL/${var}/PDL_$file
	ncea -O -d lat,43.5,44.0 -d lon,-83.0,-82.5 $file ${out_dir}PMB/${var}/PMB_$file

    done
    popd

done




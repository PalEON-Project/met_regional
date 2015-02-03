#!bin/bash
#This code loops through files and separates out met data for the 
#sites: Harvard Forest (PHA), Howland Forest (PHO), UNDERC (PUN)
#		Billy's Lake (PBL), Demming Lake (PDL), and Minden Bog (PMB)
#Original: Jaclyn Hatala Matthes, 1/14/14, jaclyn.hatala.matthes@gmail.com
#Edits: Christy Rollinson, January 2015, crollinson@gmail.com

# NOTE: This extraction was done pre-precip correction for speed
in_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp/
out_dir=/projectnb/dietzelab/paleon/met_regional/phase1a_met_drivers_v4.1/

#vars=(lwdown precipf qair swdown tair psurf wind)
vars=(psurf)
sites=(PHA PHO PUN PBL PDL PMB)

# make site dirs
if [ ! -d ${out_dir} ]
then
    mkdir ${out_dir}
fi
pushd ${out_dir}

for site in ${sites[@]}
do
if [ ! -d ${site} ]
then
    mkdir ${site}
fi

for var in ${vars[@]}
do
if [ ! -d ${out_dir}${site}/${var} ]
then 
    mkdir ${out_dir}${site}/${var}/
fi
done
done
popd

# Extract Bias-Corrected Variables (all time period)
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


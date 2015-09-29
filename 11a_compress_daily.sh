#!bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
# Script transfers & packages final bias-corrected output to folder for distribution
# Specifying in & out directories
dir_in=/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2_daily/ 
dir_out=/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2_daily/met_zip/

# Make the out directory 
mkdir -p ${dir_out}

# -----------------------
# Compress the files for transfer to iPlant
# -----------------------
vars_in=(tair precipf swdown lwdown qair psurf wind) 

for VAR in ${vars_in[@]}
do
	echo ${VAR}
	tar -jcvf ${dir_out}/${VAR}.tar.bz2 ${dir_in}${VAR}/
done
# -----------------------

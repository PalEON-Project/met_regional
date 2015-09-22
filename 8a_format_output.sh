#!bin/bash
# Script transfers & packages final bias-corrected output to folder for distribution
# Specifying in & out directories
dir_in=/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp_v2/ 
dir_out=/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2/

# Note: leave precipf_corr out because it needs to be renames
vars_in=(tair swdown lwdown qair psurf wind) 

# Make the out directory 
if[ ! -d ${dir_out} ]
then
	mkdir ${dir_out}
fi

# -----------------------
# Copy everything over to the new directory
# -----------------------
# Do precip on its own because it needs ot be renames
cp -r ${dir_in}$precipf_corr/ ${dir_out}$precipf/

# Now just copy all the remaining variables
for VAR in ${vars_in[@]}
do
	cp -r ${dir_in}$VAR/ ${dir_out}$VAR/
done
# -----------------------

# -----------------------
# Compress the files for transfer to iPlant
# -----------------------
if[ ! -d ${dir_out}$met_zip/ ]
then
	mkdir ${dir_out}$met_zip/
fi

tar -jcvf ${dir_out}$met_zip/precipf.tar.bz2 ${dir_out}$precipf

for VAR in ${vars_in[@]}
do
	tar -jcvf ${dir_out}$met_zip/${VAR}.tar.bz2 ${dir_out}$VAR
done
# -----------------------

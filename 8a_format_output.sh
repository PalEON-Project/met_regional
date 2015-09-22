# Script transfers & packages final bias-corrected output to folder for distribution
#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=60:00:00
#$ -N copy_final
#cd /projectnb/dietzelab/paleon/met_regional/

# Specifying in & out directories
dir_in=/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp_v2/ 
dir_out=/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2/

# Note: leave precipf_corr out because it needs to be renames
vars_in=(tair swdown lwdown qair psurf wind) 

# Make the out directory
if[! -d ${dir_out}]
	then
	mkdir dir_out
fi

# Do precip on its own because it needs ot be renames
cp -r ${dir_in}$precipf_corr/ ${dir_out}$precipf/

# Now just copy all the remaining variables
for VAR in ${vars_in[@]}
do
	cp -r ${dir_in}$VAR/ ${dir_out}$VAR/
done


#!bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
# Script transfers & packages final bias-corrected output to folder for distribution
# Specifying in & out directories
dir_in=/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp_v2/ 
dir_out=/projectnb/dietzelab/paleon/met_regional/phase2_met_regional_v2/

# Note: leave precipf_corr out because it needs to be renames
vars_in=(tair swdown lwdown qair psurf wind) 

# Make the out directory 
#if[ ! -d ${dirout} ]
#then
	mkdir -p ${dir_out}
#fi
# 
# # -----------------------
# # Copy everything over to the new directory
# # -----------------------
# # Do precip on its own because it needs ot be renames
# #mkdir -p ${dir_out}precipf/
# #cp ${dir_in}precipf_corr/* ${dir_out}precipf/
# 
# # Now just copy all the remaining variables
# for VAR in ${vars_in[@]}
# do
# 	echo ${VAR}
# 	mkdir -p ${dir_out}${VAR}/
# 	cp ${dir_in}${VAR}/* ${dir_out}${VAR}/
# done
# # -----------------------

# -----------------------
# Compress the files for transfer to iPlant
# -----------------------
#if[ ! -d ${dir_out}met_zip/ ]
#then
	mkdir -p ${dir_out}met_zip/
#fi

vars_in=(tair precipf swdown lwdown qair psurf wind) 

for VAR in ${vars_in[@]}
do
	echo ${VAR}
	mkdir -p ${dir_out}met_zip/${VAR}
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_0850.tar.bz2 ${dir_out}${VAR}/${VAR}_08*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_0900.tar.bz2 ${dir_out}${VAR}/${VAR}_09*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_1000.tar.bz2 ${dir_out}${VAR}/${VAR}_10*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_1100.tar.bz2 ${dir_out}${VAR}/${VAR}_11*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_1200.tar.bz2 ${dir_out}${VAR}/${VAR}_12*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_1300.tar.bz2 ${dir_out}${VAR}/${VAR}_13*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_1400.tar.bz2 ${dir_out}${VAR}/${VAR}_14*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_1500.tar.bz2 ${dir_out}${VAR}/${VAR}_15*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_1600.tar.bz2 ${dir_out}${VAR}/${VAR}_16*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_1700.tar.bz2 ${dir_out}${VAR}/${VAR}_17*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_1800.tar.bz2 ${dir_out}${VAR}/${VAR}_18*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_1900.tar.bz2 ${dir_out}${VAR}/${VAR}_19*
	tar -jcvf ${dir_out}met_zip/${VAR}/${VAR}_2000.tar.bz2 ${dir_out}${VAR}/${VAR}_20*
done
# -----------------------

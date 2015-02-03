#!bin/bash
#This code does some file structure house-keeping and makes the compressed files to send out
#Christy Rollinson, crollinson@gmail.com, January 2015

in_dir=/projectnb/dietzelab/paleon/met_regional/phase1a_met_drivers_v4.1/
out_dir=/projectnb/dietzelab/paleon/met_regional/phase1a_met_drivers_v4.1_tars/

vars=(lwdown precipf psurf qair swdown tair wind)
sites=(PHA PHO PUN PBL PDL PMB)
months=(01 02 03 04 05 06 07 08 09 10 11 12)

# ------------------------------------------
# Make Directories
# ------------------------------------------
if [ ! -d ${out_dir} ]
then
    mkdir ${out_dir}
fi
if [ ! -d ${in_dir}met_check/ ]
then
    mkdir ${in_dir}met_check/
fi


for site in ${sites[@]}
do
	if [ ! -d ${out_dir}${site} ]
	then
    	mkdir ${out_dir}${site}
	fi
done
# ------------------------------------------

# ------------------------------------------
# File house-keeping
# ------------------------------------------
# Move met_check graphs into its own folder
pushd ${in_dir}
mv *.pdf met_check/
popd

for site in ${sites[@]}
do
	# rename precip folders and overwrite wonky corrected 1900 with original bias-corrected precip
	pushd ${in_dir}${site}/
# 	mv precipf precipf_orig
# 	mv precipf_corr precipf

 	# Compressing each variable
	for var in ${vars[@]}
	do
		for m in ${months[@]}
		do
			cp ${var}/${site}_${var}_1899_${m}.nc ${var}/${site}_${var}_1900_${m}.nc
		done
		tar -jcvf ${out_dir}${site}/${var}.tar.bz2 ${var}
	done
	popd
done

# ------------------------------------------


#!bin/bash
#This file takes the output from the bias-correction and converts the continuous files into
#monthly netCDF files.
#Jaclyn Hatala Matthes, 1/22/14
#jaclyn.hatala.matthes@gmail.com

out_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/
yr_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/output/
vars=(lwdown precipf qair swdown tair)


#Make directories for organization
if [ ! -d ${yr_dir} ]
then
    mkdir ${yr_dir}
fi
pushd ${yr_dir}

for var in ${vars[@]}
do
if [ ! -d ${yr_dir}${var}/ ]
then 
    mkdir ${yr_dir}${var}/
fi
done

#Then split the files into years & then months
for var in ${vars[@]}
do
    cdo splityear ${var}_bias_corr.nc ${yr_dir}/${var}/${var}_
    for file in ${yr_dir}/${var}/*.nc
    do
	year=`echo $file | tail -c 8 | cut -c1-4`
	echo ${year}

    cdo splitmon ${yr_dir}/${var}/${var}* 
done


popd

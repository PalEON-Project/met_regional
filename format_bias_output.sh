#!bin/bash
#This file takes the output from the bias-correction and converts the continuous files into
#monthly netCDF files.
#Jaclyn Hatala Matthes, 1/22/14
#jaclyn.hatala.matthes@gmail.com

out_dir=/projectnb/cheas/paleon/met_regional/bias_corr/
yr_dir=/projectnb/cheas/paleon/met_regional/bias_corr/output/
vars=(lwdown precipf qair swdown tair)

#First merge the qair bias correction into 1 file
pushd ${out_dir}
#cdo mergetime qair_*_corr.nc qair_bias_corr.nc

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
    echo $var
    pushd ${yr_dir}${var}/
    cp ${out_dir}
    cdo splityear ${var}_bias_corr.nc ${yr_dir}${var}/${var}_
done

for var in ${vars[@]}
do
    echo $var
    for file in ${yr_dir}${var}/*.nc
    do
        echo $file
        year=`echo $file | tail -c 8 | cut -c1-4`
        echo ${year}
        cdo splitmon $file ${yr_dir}${var}/${var}_${year}_*
    done
    rm -f ${yr_dir}${var}/${var}_[0-9][0-9][0-9][0-9].nc
done

popd

#!bin/bash
#This file takes the output from the bias-correction and converts the continuous files into
#monthly netCDF files.
#Original: Jaclyn Hatala Matthes, 1/22/14, jaclyn.hatala.matthes@gmail.com
#Edits: Christy Rollinson, January 2015, crollinson@gmail.com

out_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/regional_monthly/
yr_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/final_output/
vars=(lwdown precipf psurf qair swdown tair)
# note: wind was not changed, so don't need to be resplit

#First merge the qair bias correction into 1 file
pushd ${out_dir}
echo "---------- Merge qair into 1 file ----------"
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
popd

#Then split the files into years & then months
echo "---------- Split into Years ----------"
pushd ${out_dir}
for var in ${vars[@]}
do
    echo $var
    cdo splityear ${var}_bias_corr.nc ${yr_dir}${var}/${var}_
done
popd

echo "---------- Split Years into Months ----------"
for var in ${vars[@]}
do
    echo $var
    for file in ${yr_dir}${var}/*.nc
    do
        echo $file
        year=`echo $file | tail -c 8 | cut -c1-4`
        echo ${year}
        cdo splitmon $file ${yr_dir}${var}/${var}_${year}_
    done
    rm -f ${yr_dir}${var}/${var}_[0-9][0-9][0-9][0-9].nc
done

popd

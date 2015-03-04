#!bin/bash
# This file makes the directories for the corrected leap year

out_dir=/projectnb/dietzelab/paleon/met_regional/phase1a_met_drivers_v4.2/

vars=(lwdown precipf qair swdown tair psurf wind)
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


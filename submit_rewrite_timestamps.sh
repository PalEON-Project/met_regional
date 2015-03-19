#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=12:00:00
#$ -N TimeStamps
#cd /projectnb/dietzelab/paleon/met_regional/

# outpath=/projectnb/dietzelab/paleon/met_regional/bias_corr/corr_timestamp/
# vars=(lwdown precipf psurf qair swdown tair wind)
# 
# if [ ! -d ${outpath} ]
# then
#     mkdir ${outpath}
# fi
# #pushd ${outpath}
# 
# for var in ${vars[@]}
# do
# if [ ! -d ${outpath}${var}/ ]
# then 
#     mkdir ${outpath}${var}/
# fi
# done
# #popd


R CMD BATCH rewrite_timestamps.R rewrite_timestamps.log
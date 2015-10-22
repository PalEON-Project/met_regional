#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=60:00:00
#$ -N sub2day_MaxMin
#cd /projectnb/dietzelab/paleon/met_regional/
R CMD BATCH 9c_aggregate_subday_to_day_tmax_tmin.R
#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=60:00:00
#$ -N day2mo_MaxMin
#cd /projectnb/dietzelab/paleon/met_regional/
R CMD BATCH 9d_aggregate_day_to_month_tmax_tmin.R

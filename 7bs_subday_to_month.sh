#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=60:00:00
#$ -N sub2month
#cd /projectnb/dietzelab/paleon/met_regional/
R CMD BATCH 7b_aggregate_subday_to_month.R
#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=48:00:00
#$ -N MonthQAQC
#cd /projectnb/dietzelab/paleon/met_regional/
R CMD BATCH 8b_qaqc_check_regional_month.R
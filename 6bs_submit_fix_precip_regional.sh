#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=48:00:00
#$ -N FixPrecip
#cd /projectnb/dietzelab/paleon/met_regional/
R CMD BATCH 6b_fix_precip_regional.R
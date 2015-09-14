#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=48:00:00
#$ -N FixLeap
#cd /projectnb/dietzelab/paleon/met_regional/
# sh make_leap_correct_dirs.sh
R CMD BATCH 4_add_met_leap_regional.R

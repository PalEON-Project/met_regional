#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=12:00:00
#$ -N FixLeap
#cd /projectnb/dietzelab/paleon/met_regional/
sh make_leap_correct_dirs.sh
R CMD BATCH correct_leap_year_site.R

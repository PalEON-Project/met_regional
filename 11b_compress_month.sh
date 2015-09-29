#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=60:00:00
#$ -N Compress_Month
#cd /projectnb/dietzelab/paleon/met_regional/

tar -jcvf phase2_met_regional_v2_monthly.tar.bz2 phase2_met_regional_v2_monthly

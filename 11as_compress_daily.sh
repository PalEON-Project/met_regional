#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=60:00:00
#$ -N Compress_Day
#cd /projectnb/dietzelab/paleon/met_regional/
sh 11a_compress_daily.sh

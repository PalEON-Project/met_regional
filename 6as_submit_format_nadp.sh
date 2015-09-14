#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/fix_precip/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=12:00:00
#$ -N NADP
#cd /projectnb/dietzelab/paleon/met_regional/fix_precip/
R CMD BATCH format_nadp.R
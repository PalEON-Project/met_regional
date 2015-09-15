#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=12:00:00
#$ -N NADP
#cd /projectnb/dietzelab/paleon/met_regional/
R CMD BATCH 6a_format_nadp.R
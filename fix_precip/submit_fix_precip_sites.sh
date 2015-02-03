#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/fix_precip/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=24:00:00
#$ -N SitePrecip
#cd /projectnb/dietzelab/paleon/met_regional/fix_precip/
R CMD BATCH fix_precip_sites.R
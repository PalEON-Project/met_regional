#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=12:00:00
#$ -N ParseSites
#cd /projectnb/dietzelab/paleon/met_regional/
sh parse_sites.sh
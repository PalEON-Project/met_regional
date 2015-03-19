#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=24:00:00
#$ -N CompressMet
#cd /projectnb/dietzelab/paleon/met_regional/
tar -jcvf phase1a_met_drivers_v4.1.tar.bz2 phase1a_met_drivers_v4.2
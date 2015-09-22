# Script transfers & packages final bias-corrected output to folder for distribution
#!/bin/sh
#$ -wd /projectnb/dietzelab/paleon/met_regional/
#$ -j y
#$ -S /bin/bash
#$ -V
#$ -m e
#$ -M crollinson@gmail.com
#$ -l h_rt=60:00:00
#$ -N Pack_Subday
#cd /projectnb/dietzelab/paleon/met_regional/

qsub 8a_format_output.sh

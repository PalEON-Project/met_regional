#!bin/bash
#copy ccsm4 data (850-1900) for non-bias corrected variables to directories

ccsm4base=/projectnb/dietzelab/paleon/met_regional/ccsm4/
biasbase=/projectnb/dietzelab/paleon/met_regional/bias_corr/final_output_v2/
#origbase=/projectnb/dietzelab/paleon/met_regional/phase1a_met_drivers/original/
#sites=(PMB PUN)
vars=(wind)

#for SITE in ${sites[@]}
#do
#  pushd ${ccsm4base}$SITE
    for VAR in ${vars[@]}
    do
		cp ${ccsm4base}$VAR/${VAR}_0*.nc ${biasbase}$VAR/
		cp ${ccsm4base}$VAR/${VAR}_1[0-8][0-9][0-9]_*.nc ${biasbase}$VAR/
		cp ${ccsm4base}$VAR/${VAR}_1900_*.nc ${biasbase}$VAR
	done
#  popd
#done


#!bin/bash
#copy cruncep data to directories

crubase=/projectnb/dietzelab/paleon/met_regional/cruncep/
biasbase=/projectnb/dietzelab/paleon/met_regional/bias_corr/
#origbase=/projectnb/dietzelab/paleon/met_regional/phase1a_met_drivers/original/
#sites=(PHA PHO PBL PDL PMB PUN)
vars=(lwdown precipf psurf qair swdown tair wind)

#for SITE in ${sites[@]}
#do
    pushd ${crubase}
    for VAR in ${vars[@]}
    do
		pushd $VAR
		cp *.nc ${biasbase}$VAR/
		popd
    done
    popd 
#done


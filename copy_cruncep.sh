#!bin/bash
#copy cruncep data to directories

crubase=/projectnb/cheas/paleon/met_regional/phase1a_met_drivers/original/sites/
biasbase=/projectnb/cheas/paleon/met_regional/phase1a_met_drivers/bias_corr/
origbase=/projectnb/cheas/paleon/met_regional/phase1a_met_drivers/original/
sites=(PHA PHO PBL PDL PMB PUN)
vars=(lwdown precipf psurf qair swdown tair wind)

for SITE in ${sites[@]}
do
    pushd ${crubase}$SITE
    for VAR in ${vars[@]}
    do
	pushd $VAR
	cp *.nc ${biasbase}$SITE/$VAR/
	cp *.nc ${origbase}$SITE/$VAR/
	popd
    done
    popd 
done


#!bin/bash
#copy ccsm4 data (850-1900) to directories

ccsm4base=/projectnb/cheas/paleon/met_regional/ccsm4/sites/
biasbase=/projectnb/cheas/paleon/met_regional/phase1a_met_drivers/bias_corr/
origbase=/projectnb/cheas/paleon/met_regional/phase1a_met_drivers/original/
sites=(PMB PUN)
vars=(lwdown precipf psurf qair swdown tair wind)

for SITE in ${sites[@]}
do
    pushd ${ccsm4base}$SITE
    for VAR in ${vars[@]}
    do
	pushd $VAR
	cp *${VAR}*_0[0-9][0-9][0-9]_*.nc ${origbase}$SITE/$VAR/
	cp *${VAR}*_1[0-8][0-9][0-9]_*.nc ${origbase}$SITE/$VAR/
	cp *${VAR}*_1900_*.nc ${origbase}$SITE/$VAR/

	if [[ ${VAR} == "psurf" ]]
	then
	    cp ${origbase}$SITE/$VAR/*_0[0-9][0-9][0-9]_*.nc ${biasbase}$SITE/$VAR/
	    cp ${origbase}$SITE/$VAR/*${VAR}*_1[0-8][0-9][0-9]_*.nc ${biasbase}$SITE/$VAR/
	    cp ${origbase}$SITE/$VAR/*${VAR}*_1900_*.nc ${biasbase}$SITE/$VAR
	fi

	if [[ ${VAR} == "wind" ]]
	then
	    cp ${origbase}$SITE/$VAR/*${VAR}*_0[0-9][0-9][0-9]_*.nc ${biasbase}$SITE/$VAR/
	    cp ${origbase}$SITE/$VAR/*${VAR}*_1[0-8][0-9][0-9]_*.nc ${biasbase}$SITE/$VAR/
	    cp ${origbase}$SITE/$VAR/*${VAR}*_1900_*.nc ${biasbase}$SITE/$VAR
	fi

	popd
    done
    popd 
done


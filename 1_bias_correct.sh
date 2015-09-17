#!bin/bash
#Bias-correct the downscaled 850-2005 CCSM4 time series using the CRUNCEP time series
#for the period 1961-01-01 to 1990-12-31.
#Jaclyn Hatala Matthes, 1/14/14
#jaclyn.hatala.matthes@gmail.com
# Edited by Christy Rollinson Jan 2015
# crollinson@gmail.com

module load cdo/1.6.3rc2

cru_dir=/projectnb/dietzelab/paleon/met_regional/cruncep/
gcm_dir=/projectnb/dietzelab/paleon/met_regional/ccsm4/
out_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/regional_monthly_v2/

vars=(lwdown precipf psurf qair swdown tair wind)                                                      

#Make directories for organization
if [ ! -d ${out_dir} ]
then
    mkdir ${out_dir}
fi
pushd ${out_dir}

for var in ${vars[@]}
do
if [ ! -d ${out_dir}${var}/ ]
then 
    mkdir ${out_dir}${var}/
fi
done
popd


#loop over vars and calculate the mean monthly bias b/w CRUNCEP & down-scaled GCM
echo "---------- Loop 1: Mean Bias ----------"

for var in ${vars[@]}
do
    echo $var
	echo "-- CRU --"
    pushd ${cru_dir}${var}/
    cdo cat *.nc ${out_dir}${var}_cru_cat.nc
    cdo seldate,1961-01-01,1990-12-31 ${out_dir}${var}_cru_cat.nc ${out_dir}${var}_cru_yrs.nc
    cdo ymonmean ${out_dir}${var}_cru_yrs.nc ${out_dir}${var}_cru_mmean.nc
    popd

	echo "-- GCM --"
    pushd ${gcm_dir}/${var}/
    cdo cat *.nc ${out_dir}${var}_gcm_cat.nc
    cdo seldate,1961-01-01,1990-12-31 ${out_dir}${var}_gcm_cat.nc ${out_dir}${var}_gcm_yrs.nc
    cdo ymonmean ${out_dir}${var}_gcm_yrs.nc ${out_dir}${var}_gcm_mmean.nc
    popd
done

pushd ${out_dir}
#for tair, simply subtract the bias
echo "---------- Tair Calculation ----------"
cdo sub tair_cru_mmean.nc tair_gcm_mmean.nc tair_bias.nc
cdo ymonadd tair_gcm_cat.nc tair_bias.nc tair_bias_corr.nc

#for radiation, humidity, precip, use ratios approach
echo "---------- Loop 2: Ratio Calculations ----------"
ratio_vars=(lwdown precipf psurf swdown)
# Wind has no correction; qair has it's own below

for rvar in ${ratio_vars[@]}
do
	echo $rvar
	pushd ${out_dir}
    cdo div ${rvar}_cru_mmean.nc ${rvar}_gcm_mmean.nc ${rvar}_bias.nc
    cdo setvrange,0,1000 ${rvar}_bias.nc ${rvar}_bias_adj.nc
    cdo ymonmul ${rvar}_gcm_cat.nc ${rvar}_bias_adj.nc ${rvar}_bias_corr.nc
done

popd


# ------------------------------------------------------ #
#Bias-correct the downscaled 1850-2005 CCSM4 SPECIFIC HUMIDITY (qair) time series using the CRUNCEP time series
#for the period 1961-01-01 to 1990-12-31.
#Then bias-correct the past1000 time series (850-1849) using the 30-year mean across the 1850 gap (1850-1865).
#Jaclyn Hatala Matthes, 1/22/14
#jaclyn.hatala.matthes@gmail.com

echo "---------- Loop 3: Specific Humidity ----------"
cru_dir=/projectnb/dietzelab/paleon/met_regional/cruncep/
past1000_dir=/projectnb/dietzelab/paleon/met_regional/ccsm4/ccsm4_past1000/
hist_dir=/projectnb/dietzelab/paleon/met_regional/ccsm4/ccsm4_hist/
out_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/regional_monthly_v2/

vars=(qair)

#loop over vars and calculate the mean monthly bias b/w CRUNCEP & down-scaled GCM                       
for var in ${vars[@]}
do
    echo $var

    #Calculate monthly means for CRUNCEP period
    pushd ${cru_dir}${var}/
    cdo cat *.nc ${out_dir}${var}_cru_cat.nc
    cdo seldate,1961-01-01,1990-12-31 ${out_dir}${var}_cru_cat.nc ${out_dir}${var}_cru_yrs.nc
    cdo ymonmean ${out_dir}${var}_cru_yrs.nc ${out_dir}${var}_cru_mmean.nc
    popd

    #Calculate monthly means for original CCSM4 historic period
    pushd ${hist_dir}/${var}/
    cdo cat *.nc ${out_dir}${var}_hist_cat.nc
    cdo seldate,1961-01-01,1990-12-31 ${out_dir}${var}_hist_cat.nc ${out_dir}${var}_hist_yrs.nc
    cdo ymonmean ${out_dir}${var}_hist_yrs.nc ${out_dir}${var}_hist_mmean.nc
    popd

    #Bias-correct the CCSM4 historic period to CRUNCEP 
    pushd ${out_dir}
    cdo div ${var}_cru_mmean.nc ${var}_hist_mmean.nc ${var}_bias.nc
    cdo setvrange,0,1000 ${var}_bias.nc ${var}_bias_adj.nc
    cdo ymonmul ${var}_hist_cat.nc ${var}_bias_adj.nc ${var}_hist_corr.nc

    #Calculate monthly means for first 15-years CCSM4 bias-corrected historic period
    cdo seldate,1850-01-01,1864-12-31 ${var}_hist_corr.nc ${out_dir}${var}_hist_yrs2.nc
    cdo ymonmean ${out_dir}${var}_hist_yrs2.nc ${out_dir}${var}_hist2_mmean.nc
    popd

    #Calculate monthly means for last 15-years CCSM4 past1000 period
    pushd ${past1000_dir}/${var}
    cdo cat *.nc ${out_dir}${var}_past1000_cat.nc
    cdo seldate,1825-01-01,1849-12-31 ${out_dir}${var}_past1000_cat.nc ${out_dir}${var}_past1000_yrs.nc
    cdo ymonmean ${out_dir}${var}_past1000_yrs.nc ${out_dir}${var}_past1000_mmean.nc
    popd

    #Bias-correct the CCSM4 past1000 period to corrected historic period
    pushd ${out_dir}
    cdo div ${var}_hist2_mmean.nc ${var}_past1000_mmean.nc ${var}_bias2.nc
    cdo setvrange,0,1000 ${var}_bias2.nc ${var}_bias2_adj.nc
    cdo ymonmul ${var}_past1000_cat.nc ${var}_bias2_adj.nc ${var}_past1000_corr.nc
    popd

done


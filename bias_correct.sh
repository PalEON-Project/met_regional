#!bin/bash
#Bias-correct the downscaled 850-2005 CCSM4 time series using the CRUNCEP time series
#for the period 1961-01-01 to 1990-12-31.
#Jaclyn Hatala Matthes, 1/14/14
#jaclyn.hatala.matthes@gmail.com

cru_dir=/projectnb/dietzelab/paleon/met_regional/cruncep/
gcm_dir=/projectnb/dietzelab/paleon/met_regional/ccsm4/
out_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/regional_monthly

#vars=(lwdown precipf psurf qair swdown tair wind)
vars=(lwdown wind)

#cru_dir=/projectnb/dietzelab/paleon/met_regional/cruncep/
#gcm_dir=/projectnb/dietzelab/paleon/met_regional/ccsm4/
#out_dir=/projectnb/dietzelab/paleon/met_regional/bias_corr/

#vars=(lwdown wind)

vars=(lwdown precipf psurf qair swdown tair wind)                                                      
#loop over vars and calculate the mean monthly bias b/w CRUNCEP & down-scaled GCM                       
for var in ${vars[@]}
do
    echo $var
    pushd ${cru_dir}${var}/
    cdo cat *.nc ${out_dir}${var}_cru_cat.nc
    cdo seldate,1961-01-01,1990-12-13 ${out_dir}${var}_cru_cat.nc ${out_dir}${var}_cru_yrs.nc
    cdo ymonmean ${out_dir}${var}_cru_yrs.nc ${out_dir}${var}_cru_mmean.nc
done

#loop over vars and calculate the mean monthly bias b/w CRUNCEP & down-scaled GCM
for var in ${vars[@]}
do
    echo $var
    pushd ${cru_dir}${var}/
    cdo cat *.nc ${out_dir}${var}_cru_cat.nc
    cdo seldate,1961-01-01,1990-12-13 ${out_dir}${var}_cru_cat.nc ${out_dir}${var}_cru_yrs.nc
    cdo ymonmean ${out_dir}${var}_cru_yrs.nc ${out_dir}${var}_cru_mmean.nc
    popd

    pushd ${gcm_dir}/${var}/
    cdo cat *.nc ${out_dir}${var}_gcm_cat.nc
    cdo seldate,1961-01-01,1990-12-13 ${out_dir}${var}_gcm_cat.nc ${out_dir}${var}_gcm_yrs.nc
    cdo ymonmean ${out_dir}${var}_gcm_yrs.nc ${out_dir}${var}_gcm_mmean.nc
    popd

done

pushd ${out_dir}
#for tair, simply subtract the bias
cdo sub tair_cru_mmean.nc tair_gcm_mmean.nc tair_bias.nc
cdo ymonadd tair_gcm_cat.nc tair_bias.nc tair_bias_corr.nc

#for radiation, humidity, precip, use ratios approach
ratio_vars=(lwdown precipf qair swdown)
for rvar in ${ratio_vars[@]}
do
    cdo div ${rvar}_cru_mmean.nc ${rvar}_gcm_mmean.nc ${rvar}_bias.nc
    cdo setvrange,0,1000 ${rvar}_bias.nc ${rvar}_bias_adj.nc
    cdo ymonmul ${rvar}_gcm_cat.nc ${rvar}_bias_adj.nc ${rvar}_bias_corr.nc
done

# Wind has no correction
popd
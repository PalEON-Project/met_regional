#!bin/bash
#split yearly netCDF files into month

for f in *.nc
do
    year=`echo $f | cut -c6-9`
    echo $year
    cdo splitmon $f mon/qair_${year}_
done
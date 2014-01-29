These files contain bias-correction and post-processing steps to be executed after the PalEON meteoroglogical downscaling of global circulation model output (past1000 simulation = 850-1850; historic simulation = 1850-2005) to the CRUNCEP timestep and grid (6hr, 0.5-degrees). 

The bias-correction adjusts the monthly mean of the downscaled GCM output to the monthly mean of CRUNCEP data in the overlapping 1961-1990 period, and then corrects this bias back in time to 850 for radiation, precipitation, and temperature. The bias correction for humidity is slighly different, to account for a large model jump between the past1000 and historic GCM runs. The method for this correction assumes the same monthly means from 1835-1849 and 1850-1864. 

The parse_sites commands extract the site-level Phase1a protocol data from the regional data.

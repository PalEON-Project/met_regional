Information about PalEON met driver processing.
Jaclyn Hatala Matthes, jaclyn.hatala.matthes@gmail.com
10 June 2014

This directory contains the uncorrected, bias-corrected, and final versions of both the site-level PalEON 
met drivers (Phase 1a) and regional drivers (Phase 1b). 

Directories in /projectnb/cheas/paleon/met_regional/ are as follows:
1. ccsm4/ contains the copied output from the down-scaled artificial neural network procedure. 
It is simply copied over from /projectnb/cheas/paleon/create_met/R1i1P1/Scripts/output/ann_all/$VAR/netcdf 
(Bjorn's file processing set-up).
2. cruncep/ contains the original CRUNCEP driver data downloaded by Bjorn and used to run the ANN procedure.
3. bias_corr/ contains the bias-corrected down-scaled CCSM4 output 
4. fix_precip/ contains scripts and NADP precip data used to correct the precipitation frequency distribution 
for Phase 1a and 1b bias-corrected output
5. phase1a_met_drivers_v#/ are the various versions of met drivers produced throughout the past year - only 
the most recent version should be used, as this applies all of the relevant corrections.
6. phase1b_met_regional/ contains the final version of the regional met drivers with all corrections from 
Phase 1a applied.

The processing code steps occurred in the following order:

1. Bias-correct the CCSM4 ANN down-scaled output with bias_correct.sh, writing the files to bias_corr/regional_monthly/
2. Extract sites from regional bias-corrected files to bias_corr/regional_monthly/sites/ with bias_corr/regional_monthly/parse_sites.sh
3. Use add_met_leap.R to add leap years to February months by repeating Feb 28th.
4. Use rewrite_timestamps.R to rewrite the timestamps and to make sure they are continuous days since 0850-01-01
5. Use fix_precip/fix_precip.R (for Phase 1a) or fix_precip_regional.R (for Phase 1b) to correct the 
precipitation distributions based on the 30-year daily measured precipitation at NADP sites (fix_precip/nadp/).



These files contain bias-correction and post-processing steps to be executed after the PalEON meteoroglogical downscaling of global circulation model output (past1000 simulation = 850-1850; historic simulation = 1850-2005) to the CRUNCEP timestep and grid (6hr, 0.5-degrees). 


The bias-correction adjusts the monthly mean of the downscaled GCM output to the monthly mean of CRUNCEP data in the overlapping 1961-1990 period, and then corrects this bias back in time to 850 for radiation, precipitation, and temperature. The bias correction for humidity is slighly different, to account for a large model jump between the past1000 and historic GCM runs. The method for this correction assumes the same monthly means from 1835-1849 and 1850-1864. 


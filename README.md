Information about PalEON met driver processing.
Original: Jaclyn Hatala Matthes, jaclyn.hatala.matthes@gmail.com, 10 June 2014
Updates: Christy Rollinson, crollinson@gmail.com, January 2015

This directory contains the uncorrected, bias-corrected, and final versions of both the site-level PalEON 
met drivers (Phase 1a) and regional drivers (Phase 1b). 

Directories in /projectnb/dietzelab/paleon/met_regional/ are as follows:
1. ccsm4/ contains the copied output from the down-scaled artificial neural network procedure. 
It is simply copied over from /projectnb/dietzelab/paleon/create_met/R1i1P1/Scripts/output/ann_all/$VAR/netcdf 
(Bjorn's file processing set-up).
2. cruncep/ contains the original CRUNCEP driver data downloaded by Bjorn and used to run the ANN procedure.
3. bias_corr/ contains the bias-corrected down-scaled CCSM4 output 
	— bias_corr_original is Jackie’s version that still had a jump in the CRUNCEP splice
4. fix_precip/ contains scripts and NADP precip data used to correct the precipitation frequency distribution 
for Phase 1a and 1b bias-corrected output
5. phase1a_met_drivers_v4/ is the most recent version - this one is bias-corrected and the precipitation is 
   adjusted to the disturibution from the NADP dataset.
6. phase1b_met_regional_v2/ contains the final version of the regional met drivers with all corrections from 
   Phase 1a applied.
7. phase1a/1b_old_met_releases/ is a directory that contains old met releases. v1 is the original down-scaled output, 
   and for Phase 1a, v2 is after timestamps are corrected, v3 is after bias-correction, and v4 is after precipitation 
   correction.

The processing code steps occurred in the following order:
1. Bias-correct the CCSM4 ANN down-scaled output with bias_correct.sh, writing the files to bias_corr/regional_monthly/
	— these scripts require that you load cdo/1.6.3rc2  (module load cdo/1.6.3rc2)
	- NOTE: psurf & wind do not get bias-correct
	— NOTE: qair has separate script because it requires a different correction method
2. Split files back into monthly using format_output.sh
2. Extract sites from regional bias-corrected files to bias_corr/regional_monthly/sites/ with bias_corr/regional_monthly/parse_sites.sh
	 — these scripts require you to load nco/4.3.4 (module load nco/4.3.4)
3. Use add_met_leap.R to add leap years to February months by repeating Feb 28th.
4. Use rewrite_timestamps.R to rewrite the timestamps and to make sure they are continuous days since 0850-01-01
5. Use fix_precip/fix_precip.R (for Phase 1a) or fix_precip_regional.R (for Phase 1b) to correct the 
precipitation distributions based on the 30-year daily measured precipitation at NADP sites (fix_precip/nadp/).



These files contain bias-correction and post-processing steps to be executed after the PalEON meteoroglogical downscaling of global 
circulation model output (past1000 simulation = 850-1850; historic simulation = 1850-2005) to the CRUNCEP timestep and grid (6hr, 0.5-degrees). 


The bias-correction adjusts the monthly mean of the downscaled GCM output to the monthly mean of CRUNCEP data in the overlapping 1961-1990 
period, and then corrects this bias back in time to 850 for radiation, precipitation, and temperature. The bias correction for humidity is 
slighly different, to account for a large model jump between the past1000 and historic GCM runs. The method for this correction assumes the 
same monthly means from 1835-1849 and 1850-1864. 


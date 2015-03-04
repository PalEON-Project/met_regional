PalEON Met Drivers 
Site Level
Version: 4.2
Date: 4 March 2015
Author: Christy Rollinson, crollinson@gmail.com

About PalEON Met Drivers
- Met drivers pre-1900 are based on the CCSM4 PMIP3 output that were downscaled using a neural network procedure and the CRUNCEP data.  Post-1900 values are from CRUNCEP
— Pre-1900 values have been bias-adjusted to match CRUNCEP using a subtraction- (tair) or a ratio- based process.
	— Bias-adjustment directions and scripts can be found on github (https://github.com/PalEON-Project/met_regional.git)

About version 4.1
- Previous version distributed to PalEON modeling group was supposed to be bias-dusted, but the wrong files were distributed
- Version 4.1 repeated the bias-adjustment process with a few slight modifications (see github)
- Precip was odd (almost nonexistent) in 1900, so this year repeats all met drivers from 1899 to prevent oddities that would arise from adjusting precip alone

About version 4.2
— A mistake with leap year was made in v4.1 causing years that should not have a leap year (like 900) to have one.  This version removes those extra leap years.
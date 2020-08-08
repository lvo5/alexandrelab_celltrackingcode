# Alexandre's Lab cell tracking 
## Correspondent:
  * Principal investigator: Gladys Alexandre - galexan2@utk.edu
  * Lab manager: Elena Ganusov - eganusov@utk.edu
  * Author of code: Mustafa Elmas (melmas@vols.utk.edu)
  * Lam Vo - lvo5@vols.utk.edu (Personal: lamvo1998@gmail.com), Tanmoy Mukherjee (tmukherj@vols.utk.edu)
## Citation
  * https://doi.org/10.1016/j.bpj.2019.03.006

AUTHOR: Mustafa Elmas
 
DATE: 08/01/2017

AFFILIATION: University of Tennessee - Knoxville
 
PURPOSE:

 To analyze bacterial motility videos and find 
 I)   Cell speed (micron/s)
 II)  Cell reversal frequency (/s)
 III) Mean square displacement (MSD) 
 
 1. Split a recorded video into certain number of frames

 2. Convert the frames into binary frames

 3. Calculate Centroid, Major and Minor axis length and angle
 by MATLAB built-in function, regiongroup.

 4. Constructs n-dimensional trajectories from a scrambled 
 list of particle coordinates determined at discrete times 
 in consecutive video frames by MATLAB version of cell-tracking 
 algorithm by Crocker and Grier.
 
 5. Trajectories slower than 10 microns/second and shorter than 1 s were 
 excluded from the analysis. This ensures that we restrict our 
 analysis mostly to trajectories that lie in a narrow zone around 
 the focal plane.
 
 6. Calculate velocity, reversal frequency, acceleration, angular
 acceleration, velocity autocorrelation, Mean Square Displacement

## Prerequisite:

1) MATLAB version R2019a – The version of MATLAB is important since the syntax of MATLAB may be updated due to version upgrade. Using the code in another version of MATLAB might result in unmatched syntax that will lead to errors. 
2) MATLAB has to have the image processing toolbox, statistic toolbox, and mapping toolbox. For instruction on adding toolbox, https://www.mathworks.com/help/matlab/matlab_external/support-package-installation.html#:~:text=You%20install%20support%20packages%20using,Ons%20%3E%20Get%20Hardware%20Support%20Packages.

3) A 30 seconds (anymore duration than this will result in disordered combinatorics in the tracking process that will results in shorter tracks) video for analysis has to be in good quality for quality analysis (meaning bad video = bad data). The heuristics of a good video are clear visuals of moving bacteria, the population of cell is not too dense (20-30 cells per video should be the number of cells that one shoots for), interrupted frames, and no environmental 

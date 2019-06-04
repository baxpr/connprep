# connprep

Produce preprocessed fMRI images ready for connectivity analysis.

## Pipeline

1. Drop initial or final volumes as specified. Default: Analyze all volumes.
1. Get the TR (volume acquisition time) from pixdim[4] field of the Nifti header.
1. Slice timing correction. Default: none.
1. Head motion realignment (SPM12 two-stage) and production of mean fMRI.
1. Rigid body coregistration of mean fMRI to T1 structural.
1. Compute volume quality metrics FD, DVARS.
1. Reslice realigned fMRI to native space, and also warp to MNI space using CAT12 transform.
1. Remove confounds from the native and MNI space fMRIs by simultaneous regression. Defaults:
    a. 0.01 - 0.10 Hz bandpass filter
	a. 6 estimated motion parameters and their first differences
	a. 6 principal components from the white matter + CSF compartment
1. Repeat the confound removal, additionally removing the mean signal of the gray matter compartment.

## Inputs

## Outputs


Output in native space and MNI space (cat12 transform). Unsmoothed only.

With and without mean gray matter signal removal.

No scrubbing.

Follow new fmriqa v4.2 for SPM setup.

Pass processing options at command line instead of param file.

Get TR from pixdim[4] in Niftis. Make a really obvious report of it in PDF and do some basic error checking (some people have store msec instead of sec). dcm2niix v1.0.20190410 seems fine for this with both DICOM and PAR/REC.

Show Yeo 7 connectivity maps for QA: masimatlab/trunk/xnatspiders/matlab/fmri_conncalc_v1_1_0/code/make_network_maps.m
Also show the 7x7 connectivity matrix for those.


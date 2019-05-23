Produce preprocessed fMRI images ready for connectivity analysis.

Output in native space and MNI space (cat12 transform). Unsmoothed only.

With and without mean gray matter signal removal.

No scrubbing.

Follow new fmriqa v4.2 for SPM setup.

Pass processing options at command line instead of param file.

Get TR from pixdim[4] in Niftis. Make a really obvious report of it in PDF and do some basic error checking (some people have store msec instead of sec). dcm2niix v1.0.20190410 seems fine for this with both DICOM and PAR/REC.

Show Yeo 7 connectivity maps for QA: masimatlab/trunk/xnatspiders/matlab/fmri_conncalc_v1_1_0/code/make_network_maps.m
Also show the 7x7 connectivity matrix for those.


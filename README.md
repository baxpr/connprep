Produce preprocessed fMRI images ready for connectivity analysis.

Output in native space and MNI space (cat12 transform).

With and without mean gray matter signal removal.

Follow new fmriqa v4.2 for SPM setup.

Pass processing options at command line instead of param file?

Get volume acq time from DICOM passed in along with NIFTI? Would need to handle PARREC as well. Check if our nifti converter uses pixdim[4] for this - for TCP DICOMs, yes, with whichever dcm2nii we originally used and also with v1.0.20190410. Also v1.0.20190410 appears to do this for old PARs.

Include scrubbing option?

No connmat or conn image outputs. ... would be helpful to have a few basic conn maps shown for QA though, e.g. for the Yeo networks. masimatlab/trunk/xnatspiders/matlab/fmri_conncalc_v1_1_0/code/make_network_maps.m
Could also show the 7x7 connectivity matrix for those.

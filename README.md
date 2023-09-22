# connprep

Produce preprocessed fMRI images ready for connectivity analysis.

## Pipeline

1. Drop initial or final volumes as specified. Default: Analyze all volumes.
1. Get the TR (volume acquisition time) from pixdim[4] field of the Nifti header.
1. Slice timing correction. Default: none.
1. Head motion realignment (SPM12 two-stage) and production of mean fMRI.
1. Rigid body coregistration of mean fMRI to T1 structural. The registration target
    is the provided T1 (commonly the bias-corrected T1 from CAT12) with everything 
    but white/gray/CSF masked out - i.e. effectively skull-stripped.
1. Compute volume quality metrics FD, DVARS.
1. Reslice realigned fMRI to native space, and also warp to MNI space using CAT12 transform.
1. Remove confounds from the native and MNI space fMRIs by simultaneous regression. Defaults:
    - 0.01 - 0.10 Hz bandpass filter
	- 6 estimated motion parameters and their first differences
	- 6 principal components from the white matter + CSF compartment
1. Repeat the confound removal, additionally removing the mean signal of the gray matter compartment.

## Inputs

	num_initial_vols_to_drop      0       Number of initial volumes to drop
	num_vols_to_analyze           all     Total number of volumes to analyze
	bandpasslo_hz                 0.01    Low edge of bandpass filter in Hz
	bandpasshi_hz                 0.10    High edge of bandpass filter
	mot_PCs                       6       Number of PCs of motion params to remove
	motderiv_PCs                  6       Same for motion derivatives
	wmcsf_PCs                     6       Same for white matter/CSF compartment
	slorder                       none    Slice timing correction, SPM12 nomenclature 
	fmri_niigz                            fMRI images, 4D Nifti
	mt1_niigz                             T1 structural
	deffwd_niigz                          Forward deformation of T1 to MNI
	gray_niigz                            Gray matter volume fraction
	white_niigz                           White matter volume fraction
	csf_niigz                             CSF volume fraction
	project                               XNAT project label
	subject                               XNAT subject label
	session                               XNAT session label
	scan                                  XNAT scan label
    
    # To use fmri that has already been motion corrected (in this case slice timing
    # correction is also skipped):
    skip_realignment                      Set 'true'
    motparams                             Motion parameters text file (FSL format assumed)
    meanfmri_niigz                        Mean fmri from motion correction


## Outputs

    connprep.pdf                               Processing report
    FD.txt                                     Framewise displacement
    DVARS.txt                                  Framewise noise
    stats_keepgm_noscrub.txt                   Processing info when gray matter signal retained
    stats_removegm_noscrub.txt                 Processing info when gray matter signal removed
    gm_mask.nii.gz                             Native space gray matter mask
    wmcsf_mask.nii.gz                          Native space white matter/CSF mask
    confounds_keepgm_noscrub.txt               Confounds matrix when gray matter signal retained
    confounds_removegm_noscrub.txt             Confounds matrix  when gray matter signal removed
    
    # If realignment is performed:
    rp_adfmri.txt                              Realignment parameters
    filtered_keepgm_noscrub_nadfmri.nii.gz     Filtered data, native space, gray matter signal retained
    filtered_keepgm_noscrub_wadfmri.nii.gz     Filtered data, MNI space, gray matter signal retained
    filtered_removegm_noscrub_nadfmri.nii.gz   Filtered data, native space, gray matter signal removed
    filtered_removegm_noscrub_wadfmri.nii.gz   Filtered data, MNI space, gray matter signal removed
    meanadfmri.nii.gz                          Mean fMRI, native space
	wmeanadfmri.nii.gz                         Mean fMRI, MNI space
    
    # If realignment is NOT performed:
    filtered_keepgm_noscrub_nfmri.nii.gz       Native space
    filtered_removegm_noscrub_nfmri.nii.gz
    filtered_keepgm_noscrub_wfmri.nii.gz       MNI space
    filtered_removegm_noscrub_wfmri.nii.gz
    meanfmri.nii.gz
    wmeanfmri.nii.gz

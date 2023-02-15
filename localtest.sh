#!/usr/bin/env bash


# Native space version w smoothing
docker run \
    --mount type=bind,src=`pwd -P`/INPUTS,dst=/INPUTS \
    --mount type=bind,src=`pwd -P`/OUTPUTS,dst=/OUTPUTS \
    --mount type=bind,src=`pwd -P`/freesurfer_license.txt,dst=/usr/local/freesurfer/.license \
    baxterprogers/conncalc:v1.2.0-beta2 \
    --mask_niigz /INPUTS/p0t1.nii.gz \
    --roi_niigz Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz \
    --roidefinv_niigz /INPUTS/iy_t1.nii.gz \
    --removegm_niigz /INPUTS/filtered_removegm_noscrub_nadfmri.nii.gz \
    --keepgm_niigz /INPUTS/filtered_keepgm_noscrub_nadfmri.nii.gz \
    --meanfmri_niigz /INPUTS/meanadfmri.nii.gz \
    --t1_niigz /INPUTS/mt1.nii.gz \
    --connmaps_out yes \
    --fwhm 6 \
    --out_dir /OUTPUTS




exit 0

# Use cat12 BIAS_CORR for t1 and ICV_NATIVE for mask
docker run \
    --mount type=bind,src=`pwd -P`/INPUTS,dst=/INPUTS \
    --mount type=bind,src=`pwd -P`/OUTPUTS,dst=/OUTPUTS \
    --mount type=bind,src=`pwd -P`/freesurfer_license.txt,dst=/usr/local/freesurfer/.license \
    conncalc:test \
    --mask_niigz /INPUTS/p0t1.nii.gz \
    --roi_niigz Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz \
    --roidefinv_niigz /INPUTS/iy_t1.nii.gz \
    --removegm_niigz /INPUTS/filtered_removegm_noscrub_nadfmri.nii.gz \
    --keepgm_niigz /INPUTS/filtered_keepgm_noscrub_nadfmri.nii.gz \
    --meanfmri_niigz /INPUTS/meanadfmri.nii.gz \
    --t1_niigz /INPUTS/t1.nii.gz \
    --connmaps_out yes \
    --out_dir /OUTPUTS

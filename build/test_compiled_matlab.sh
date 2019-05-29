#!/bin/bash

# Fix imagemagick policy to allow PDF output. See https://usn.ubuntu.com/3785-1/
sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' \
/etc/ImageMagick-6/policy.xml

# Run the compiled matlab  
bash ../bin/run_spm12.sh /usr/local/MATLAB/MATLAB_Runtime/v92 function connprep \
num_initial_vols_to_drop 0 \
num_vols_to_analyze all \
bandpasslo_hz 0.01 \
bandpasshi_hz 0.10 \
mot_PCs 6 \
motderiv_PCs 6 \
wmcsf_PCs 6 \
slorder none \
fmri_niigz ../INPUTS/fmri.nii.gz \
mt1_niigz ../INPUTS/mt1.nii.gz \
deffwd_niigz ../INPUTS/y_t1.nii.gz \
gray_niigz ../INPUTS/p1t1.nii.gz \
white_niigz ../INPUTS/p2t1.nii.gz \
csf_niigz ../INPUTS/p3t1.nii.gz \
project UNK_PROJ \
subject UNK_SUBJ \
session UNK_SESS \
scan UNK_SCAN \
out_dir ../OUTPUTS

#!/bin/sh

singularity \
run \
--cleanenv \
--home `pwd`/INPUTS \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
baxpr-connprep-master-v1.0.0.simg \
/OUTPUTS \
/INPUTS/t1.nii.gz \
/INPUTS/seg.nii.gz \
/INPUTS/fmri.nii.gz \
UNK_PROJ \
600000000001 \
600000000001 \
50362

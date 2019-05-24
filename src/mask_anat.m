function [mmt1_nii,mask_nii] = mask_anat( ...
	mt1_nii,gray_nii,white_nii,csf_nii)

Vgray = spm_vol(gray_nii);
Ygray = spm_read_vols(Vgray);

Vwhite = spm_vol(white_nii);
Ywhite = spm_read_vols(Vwhite);

Vcsf = spm_vol(csf_nii);
Ycsf = spm_read_vols(Vcsf);

Vmt1 = spm_vol(mt1_nii);
Ymt1 = spm_read_vols(Vmt1);

Ymask = Ygray + Ywhite + Ycsf;
Ymask = Ymask > 0.1;
Vmask = Vgray;
mask_nii = [fileparts(mt1_nii) filesep 'mask.nii'];
Vmask.fname = mask_nii;
Vmask.pinfo(1:2) = [1 0]';
spm_write_vol(Vmask,Ymask);

Ymmt1 = Ymt1 .* Ymask;
Vmmt1 = Vmt1;
mmt1_nii = [fileparts(mt1_nii) filesep 'mt1_masked.nii'];
Vmmt1.fname = mmt1_nii;
spm_write_vol(Vmmt1,Ymmt1);


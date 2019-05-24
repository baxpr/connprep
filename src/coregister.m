function [cradfmri_nii,cmeanradfmri_nii] = coregister( ...
    radfmri_nii,meanradfmri_nii,mt1_nii)

% Coregister mean func to ct1
flags = struct( ...
	'sep',[4 2], ...
	'cost_fun','nmi', ...
	'tol',[0.02 0.02 0.02 0.001 0.001 0.001], ...
	'fwhm',[7 7] ...
	);
Vref = spm_vol(mt1_nii);
Vsource = spm_vol(meanradfmri_nii);
coreg_params = spm_coreg(Vref,Vsource,flags);
coreg_mat = spm_matrix(coreg_params(:)');

% Filenames for coregistered images. We haven't changed them because we
% never did a reslice.
cradfmri_nii = radfmri_nii;
cmeanradfmri_nii = meanradfmri_nii;


function [cradfmri_nii,cmeanradfmri_nii] = coregister( ...
    radfmri_nii,meanradfmri_nii,mt1_nii)

% Coregister mean func to mt1
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

% Apply the coregistration to the func file headers (same procedure as
% above)
V = spm_vol(meanradfmri_nii);
Y = spm_read_vols(V);
V.mat = coreg_mat \ V.mat;
spm_write_vol(V,Y);

% We expect the "Warning: Forcing deletion of MAT-file." for the first
% volume. It's ok because we have captured the info in the geometry .mat
% file with the first line here, and we are saving it back.
V = spm_vol(radfmri_nii);
for v = 1:length(V)
	Vout = V(v);
	Y = spm_read_vols(Vout);
	Vout.mat = coreg_mat \ Vout.mat;
	spm_write_vol(Vout,Y);
end

% Filenames for coregistered images. We haven't changed them because we
% never did a reslice.
cradfmri_nii = radfmri_nii;
cmeanradfmri_nii = meanradfmri_nii;


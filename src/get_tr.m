function tr = get_tr(fmri_nii)

% TR should be in pixdim[4] (the 5th element) and should be in sec
nii = nifti(fmri_nii);
tr = nii.timing.tspace;
fprintf('Discovered TR = %f\n',tr)
if tr<0.2 || tr>5
	warning('Unusual volume acquisition time %f',tr)
end

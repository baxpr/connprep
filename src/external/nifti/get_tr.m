function tr = get_tr(fmri_nii)

% TR should be in pixdim[4] (the 5th element) and should be in sec
nii = load_untouch_nii(fmri_nii);
tr = nii.hdr.dime.pixdim(5);
fprintf('Discovered TR = %f\n',tr)
if tr<0.2 || tr>5
	warning('Unusual volume acquisition time %f',tr)
end

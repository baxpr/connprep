function dfmri_nii = drop_volumes( ...
	fmri_nii,num_initial_vols_to_drop,num_vols_to_analyze)

% Drop initial volumes to account for saturation effects. Assumes 4D Nifti.

% Load images and count volumes
V = spm_vol(fmri_nii);
Y = spm_read_vols(V);
total_vols = size(Y,4);

% If we don't have a drop count, make it zero
if isempty(num_initial_vols_to_drop)
	num_initial_vols_to_drop = '0';
end

% If we don't have a vol limit, use them all
if isempty(num_vols_to_analyze)
	num_vols_to_analyze = 'all';
end	

% Convert from string to int
num_initial_vols_to_drop = str2num(num_initial_vols_to_drop);
if strcmp(num_vols_to_analyze,'all')
	num_vols_to_analyze = total_vols - num_initial_vols_to_drop;
else
	num_vols_to_analyze = str2num(num_vols_to_analyze);
end

% Check that things make sense
if (num_initial_vols_to_drop + num_vols_to_analyze) > total_vols
	error('More volumes requested than exist in %s',fmri_nii)
end

% Drop volumes
keeps = (1:num_vols_to_analyze) + num_initial_vols_to_drop;
outV = V(keeps);
outY = Y(:,:,:,keeps);

% Output filename and updated indices, and write
[fmri_p,fmri_n,fmri_e] = fileparts(fmri_nii);
dfmri_nii = fullfile(fmri_p,['d' fmri_n fmri_e]);
for v = 1:length(outV)
	outV(v).fname = dfmri_nii;
	outV(v).n(1) = v;
	spm_write_vol(outV(v),outY(:,:,:,v));
end


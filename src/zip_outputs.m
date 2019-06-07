function zip_outputs(out_dir)

% Zip images
system([ ...
	'cd ' out_dir ' && gzip -f ' ...
	'filtered_keepgm_noscrub_nadfmri.nii ' ...
	'filtered_keepgm_noscrub_wadfmri.nii ' ...
	'filtered_removegm_noscrub_nadfmri.nii ' ...
	'filtered_removegm_noscrub_wadfmri.nii ' ...
	'meanadfmri.nii ' ...
	'wmeanadfmri.nii ' ...
	'gm_mask.nii ' ...
	'wmcsf_mask.nii ' ...
	'redge_wgray.nii ' ...
	'rwmask.nii ' ...
	]);


% Clean up intermediate files
%delete([out_dir '/*.png']);
%delete([out_dir '/*.nii']);

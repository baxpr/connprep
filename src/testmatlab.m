% SPM12 needs to be in the path also
addpath(genpath('.'))

connprep( ...
	'wroi_file',which('rois_JSins.nii.gz'), ...
	'roi_file','', ...
	'roiinfo_file',which('rois_JSins.csv'), ...
	'coregmat_file','../INPUTS/coreg_mat.txt', ...
	'deffwd_file','../INPUTS/y_deffwd.nii.gz', ...
	'ct1_file','../INPUTS/ct1.nii.gz', ...
	'wgm_file','../INPUTS/wgm.nii.gz', ...
	'wcseg_file','../INPUTS/wcseg.nii.gz', ...
	'func_file','../INPUTS/fmri.nii.gz', ...
	'project','UNK_PROJ', ...
	'subject','UNK_SUBJ', ...
	'session','UNK_SESS', ...
	'scan','UNK_SCAN', ...
	'out_dir','../OUTPUTS' ...
	);

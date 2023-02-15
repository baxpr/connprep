%% SPM12 needs to be in the path also
addpath('.')


%% Previous way (with realignment)
connprep( ...
	'num_initial_vols_to_drop','0', ...
	'num_vols_to_analyze','all', ...
	'bandpasslo_hz','0.01', ...
	'bandpasshi_hz','0.10', ...
	'mot_PCs','6', ...
	'motderiv_PCs','6', ...
	'wmcsf_PCs','6', ...
	'slorder','none', ...
	'fmri_niigz','../INPUTS/fmri.nii.gz', ...
	'mt1_niigz','../INPUTS/mt1.nii.gz', ...
	'deffwd_niigz','../INPUTS/y_t1.nii.gz', ...
	'gray_niigz','../INPUTS/p1t1.nii.gz', ...
	'white_niigz','../INPUTS/p2t1.nii.gz', ...
	'csf_niigz','../INPUTS/p3t1.nii.gz', ...
	'mnigeom_nii','avg152T1.nii', ...
	'out_dir','../OUTPUTS_old' ...
	);


%% New way (skip realignment)
connprep( ...
    'skip_realignment','true', ...
    'meanfmri_niigz','../INPUTS/umeanfmri.nii.gz', ...
    'motparams','../INPUTS/motpar.txt', ...
	'num_initial_vols_to_drop','0', ...
	'num_vols_to_analyze','all', ...
	'bandpasslo_hz','0.01', ...
	'bandpasshi_hz','0.10', ...
	'mot_PCs','6', ...
	'motderiv_PCs','6', ...
	'wmcsf_PCs','6', ...
	'fmri_niigz','../INPUTS/ufmri.nii.gz', ...
	'mt1_niigz','../INPUTS/mt1.nii.gz', ...
	'deffwd_niigz','../INPUTS/y_t1.nii.gz', ...
	'gray_niigz','../INPUTS/p1t1.nii.gz', ...
	'white_niigz','../INPUTS/p2t1.nii.gz', ...
	'csf_niigz','../INPUTS/p3t1.nii.gz', ...
	'mnigeom_nii','avg152T1.nii', ...
	'out_dir','../OUTPUTS_new' ...
	);

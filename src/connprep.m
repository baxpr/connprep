function connprep(varargin)


%% Parse inputs
P = inputParser;

addOptional(P,'num_initial_vols_to_drop','0')
addOptional(P,'num_vols_to_analyze','all')
addOptional(P,'bandpasslo_hz','0.01')
addOptional(P,'bandpasshi_hz','0.10')
addOptional(P,'mot_PCs','6')
addOptional(P,'motderiv_PCs','6')
addOptional(P,'wmcsf_PCs','6')
addOptional(P,'slorder','none')

addOptional(P,'fmri_niigz','/INPUTS/fmri.nii.gz');
addOptional(P,'mt1_niigz','/INPUTS/mt1.nii.gz');
addOptional(P,'deffwd_niigz','/INPUTS/y_t1.nii.gz');
addOptional(P,'gray_niigz','/INPUTS/p1t1.nii.gz');
addOptional(P,'white_niigz','/INPUTS/p2t1.nii.gz');
addOptional(P,'csf_niigz','/INPUTS/p3t1.nii.gz');

addOptional(P,'mnigeom_nii','avg152T1.nii')

addOptional(P,'project','UNK_PROJ');
addOptional(P,'subject','UNK_SUBJ');
addOptional(P,'session','UNK_SESS');
addOptional(P,'scan','UNK_SCAN');

addOptional(P,'magick_path','/usr/bin');

addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});

disp(P.Results)


%% Process
connprep_main(P.Results)


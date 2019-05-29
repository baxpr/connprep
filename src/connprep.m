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

addOptional(P,'project','UNK_PROJ');
addOptional(P,'subject','UNK_SUBJ');
addOptional(P,'session','UNK_SESS');
addOptional(P,'scan','UNK_SCAN');

addOptional(P,'magick_path','/usr/bin');

addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});

num_initial_vols_to_drop = P.Results.num_initial_vols_to_drop;
num_vols_to_analyze = P.Results.num_vols_to_analyze;
bandpasslo_hz = P.Results.bandpasslo_hz;
bandpasshi_hz = P.Results.bandpasshi_hz;
mot_PCs = P.Results.mot_PCs;
motderiv_PCs = P.Results.motderiv_PCs;
wmcsf_PCs = P.Results.wmcsf_PCs;
slorder = P.Results.slorder;

fmri_niigz = P.Results.fmri_niigz;
mt1_niigz = P.Results.mt1_niigz;
deffwd_niigz = P.Results.deffwd_niigz;
gray_niigz = P.Results.gray_niigz;
white_niigz = P.Results.white_niigz;
csf_niigz = P.Results.csf_niigz;

project = P.Results.project;
subject = P.Results.subject;
session = P.Results.session;
scan    = P.Results.scan;

magick_path = P.Results.magick_path;

out_dir = P.Results.out_dir;

fprintf('%s %s %s\n',project,subject,session);
fprintf('fmri scan:   %s\n',scan);
fprintf('fmri_niigz:  %s\n',fmri_niigz);
fprintf('mt1_niigz:   %s\n',mt1_niigz);
fprintf('out_dir:     %s\n',out_dir);


%% Process
connprep_main( ...
	num_initial_vols_to_drop, ...
	num_vols_to_analyze, ...
	bandpasslo_hz, ...
	bandpasshi_hz, ...
	mot_PCs, ...
	motderiv_PCs, ...
	wmcsf_PCs, ...
	slorder, ...
	fmri_niigz, ...
	mt1_niigz, ...
	deffwd_niigz, ...
	gray_niigz, ...
	white_niigz, ...
	csf_niigz, ...
	project, ...
	subject, ...
	session, ...
	scan, ...
	magick_path, ...
	out_dir ...
	)


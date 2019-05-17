function connprep(varargin)


%% Parse inputs
P = inputParser;
addOptional(P,'num_initial_vols_to_drop','0')
addOptional(P,'num_vols_to_analyze','all')
addOptional(P,'spatialsmooth_fwhm','6')
addOptional(P,'bandpasslo_hz','0.01')
addOptional(P,'bandpasshi_hz','0.10')
addOptional(P,'mot_PCs','6')
addOptional(P,'motderiv_PCs','6')
addOptional(P,'wmcsf_PCs','6')
addOptional(P,'slorder','none')

addOptional(P,'coregmat_file','/INPUTS/coreg_mat.txt');
addOptional(P,'deffwd_file','/INPUTS/y_deffwd.nii.gz');
addOptional(P,'ct1_file','/INPUTS/ct1.nii.gz');
addOptional(P,'wgm_file','/INPUTS/wgm.nii.gz');
addOptional(P,'wcseg_file','/INPUTS/wcseg.nii.gz');
addOptional(P,'func_file','/INPUTS/fmri.nii.gz');
addOptional(P,'project','UNK_PROJ');
addOptional(P,'subject','UNK_SUBJ');
addOptional(P,'session','UNK_SESS');
addOptional(P,'scan','UNK_SCAN');
addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});


coregmat_file = P.Results.coregmat_file;
deffwd_file = P.Results.deffwd_file;
ct1_file = P.Results.ct1_file;
wgm_file = P.Results.wgm_file;
wcseg_file = P.Results.wcseg_file;
func_file = P.Results.func_file;
project = P.Results.project;
subject = P.Results.subject;
session = P.Results.session;
scan = P.Results.scan;
out_dir = P.Results.out_dir;
if ~isempty(P.Results.roiinfo_file)
	copyfile(which(P.Results.roiinfo_file),fullfile(out_dir,'roi_labels.csv'));
else
	fid = fopen(fullfile(out_dir,'roi_labels.csv'),'wt');
	fprintf(fid,'No ROI label info available\n');
	fclose(fid);
end

fprintf('param_file:   %s\n',param_file);
fprintf('roi_file:     %s\n',roi_file);
fprintf('wroi_file:    %s\n',wroi_file);
fprintf('roiinfo_file: %s\n',roiinfo_file);



%% Copy files to working directory with consistent names and unzip
disp('File prep')
[coregmat_file,deffwd_file,ct1_file,wgm_file,wcseg_file,func_file,wroi_file] = ...
	prep_files( ...
	out_dir,coregmat_file,deffwd_file,ct1_file,wgm_file,wcseg_file,func_file, ...
	wroi_file);
movefile(wroi_file,fullfile(out_dir,'wroi_labels.nii'));
wroi_file = fullfile(out_dir,'wroi_labels.nii');


%% Drop unwanted volumes
fprintf('Drop volumes from %s\n',func_file);
dfunc_file = drop_volumes(func_file,params);


%% Slice timing correction
% Slice timing correction interpolates across time, possibly polluting high
% quality vols with artifact signal from nearby vols with high FD/DVARS
fprintf('Slice timing correction on %s\n',dfunc_file);
adfunc_file = slice_timing_correction(dfunc_file,params);


%% Realignment
fprintf('Realignment of %s\n',adfunc_file);
[radfunc_file,meanradfunc_file,rp_file] = realignment(adfunc_file);


%% Coregister to anat
fprintf('Coregister:\n    %s\n    %s\n',meanradfunc_file,ct1_file)
[cradfunc_file,cmeanradfunc_file] = coregister( ...
	radfunc_file,meanradfunc_file,ct1_file,coregmat_file);


%% Compute FD, DVARS
disp('Volume quality')
[FD,DVARS,badvols] = volume_quality(out_dir,cmeanradfunc_file,cradfunc_file, ...
	rp_file,params.scrub_FDthresh,params.scrub_DVARSthresh);


%% Warp T1 to MNI space for testing
warp_images(deffwd_file,ct1_file, ...
	[spm('dir') '/canonical/avg152T1.nii'],1,out_dir);


%% Warp fMRI to MNI space
fprintf('Warping:\n    %s\n    %s\n',cmeanradfunc_file,cradfunc_file);
wmeanfunc_file = warp_images(deffwd_file,cmeanradfunc_file, ...
	[spm('dir') '/canonical/avg152T1.nii'],1,out_dir);
wfunc_file = warp_images(deffwd_file,cradfunc_file, ...
	[spm('dir') '/canonical/avg152T1.nii'],1,out_dir);
coreg_check(out_dir,wmeanfunc_file,wgm_file);


%% Smooth the fMRI images
%fprintf('Smoothing %s\n',wfunc_file);
%swfunc_file = smooth(wfunc_file,params);


%% Resample ROI image and compute ROI SNR from the unsmoothed images
wroi_file = roi_snr(out_dir,wfunc_file,wroi_file);


%% Process fMRI: filter, extract signals, compute connectivity

disp('Connectivity')

% Remove gray matter signal, scrub
connectivity_filter( out_dir, ...
	badvols,rp_file,wcseg_file,wfunc_file,wroi_file,params, ...
	1,FD,DVARS,project,subject,session,scan );

% Remove gray matter signal, no scrub
connectivity_filter( out_dir, ...
	[],rp_file,wcseg_file,wfunc_file,wroi_file,params, ...
	1,FD,DVARS,project,subject,session,scan );

% Keep gray matter signal, scrub
connectivity_filter( out_dir, ...
	badvols,rp_file,wcseg_file,wfunc_file,wroi_file,params, ...
	0,FD,DVARS,project,subject,session,scan );

% Keep gray matter signal, no scrub
connectivity_filter( out_dir, ...
	[],rp_file,wcseg_file,wfunc_file,wroi_file,params, ...
	0,FD,DVARS,project,subject,session,scan );


%% Make output PDF
make_pdf(out_dir,magick_path);


%% Zip output images
zip_outputs(out_dir,params);


%% Exit
if isdeployed
	exit
end


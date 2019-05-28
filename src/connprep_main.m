function connprep_main( ...
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
	out_dir ...
	)



%% Copy files to working directory with consistent names and unzip
disp('File prep')
[fmri_nii,mt1_nii,deffwd_nii,gray_nii,white_nii,csf_nii] = prep_files( ...
	out_dir,fmri_niigz,mt1_niigz,deffwd_niigz,gray_niigz,white_niigz,csf_niigz);


%% Drop unwanted volumes
fprintf('Drop volumes from %s\n',fmri_nii);
dfmri_nii = drop_volumes(fmri_nii,num_initial_vols_to_drop,num_vols_to_analyze);


%% Find the TR
tr = get_tr(fmri_nii);


%% Slice timing correction
% Slice timing correction interpolates across time, possibly polluting high
% quality vols with artifact signal from nearby vols with high FD/DVARS
fprintf('Slice timing correction "%s" on %s\n',slorder,dfmri_nii);
adfmri_nii = slice_timing_correction(dfmri_nii,tr,slorder);


%% Realignment
fprintf('Realignment of %s\n',adfmri_nii);
[radfmri_nii,meanradfmri_nii,rp_txt] = realignment(adfmri_nii);


%% Make masked anat
[mmt1_nii,mask_nii] = mask_anat(mt1_nii,gray_nii,white_nii,csf_nii);


%% Coregister to anat
fprintf('Coregister:\n    %s\n    %s\n',meanradfmri_nii,mmt1_nii)
[cradfmri_nii,cmeanradfmri_nii] = coregister( ...
	radfmri_nii,meanradfmri_nii,mmt1_nii);


%% Reslice images to native space post-realignment
ncradfmri_nii = reslice(cradfmri_nii,cmeanradfmri_nii);


%% Compute FD, DVARS
disp('Volume quality')
[FD,DVARS] = volume_quality(out_dir,cmeanradfmri_nii,ncradfmri_nii,rp_txt);


%% Warp T1 and gray to MNI space
wmt1_nii = warp_images(deffwd_nii,mt1_nii, ...
	[spm('dir') '/canonical/avg152T1.nii'],1,out_dir);
wgray_nii = warp_images(deffwd_nii,gray_nii, ...
	[spm('dir') '/tpm/TPM.nii'],1,out_dir);


%% Warp fMRI to MNI space
fprintf('Warping:\n    %s\n    %s\n',cmeanradfmri_nii,cradfmri_nii);
wcmeanradfmri_nii = warp_images(deffwd_nii,cmeanradfmri_nii, ...
	[spm('dir') '/canonical/avg152T1.nii'],1,out_dir);
wcradfmri_nii = warp_images(deffwd_nii,cradfmri_nii, ...
	[spm('dir') '/canonical/avg152T1.nii'],1,out_dir);
coreg_check(out_dir,wcmeanradfmri_nii,wgray_nii);


%% Process fMRI: filter, extract signals, compute connectivity

disp('Connectivity')

% Remove gray matter signal, no scrub
connectivity_filter( out_dir, ...
	[],rp_file,wcseg_file,wfunc_file,wroi_file,params, ...
	1,FD,DVARS,project,subject,session,scan );

% Keep gray matter signal, no scrub
connectivity_filter( out_dir, ...
	[],rp_file,wcseg_file,wfunc_file,wroi_file,params, ...
	0,FD,DVARS,project,subject,session,scan );


%% Make output PDF
make_pdf(out_dir);


%% Zip output images
zip_outputs(out_dir);


%% Exit
if isdeployed
	exit
end


function connprep_main(inp)

% Inputs are the parser results structure from connprep.m


%% SPM init
spm_jobman('initcfg')

%% Get reference geometry
mnigeom_nii = which(inp.mnigeom_nii);


%% Copy files to working directory with consistent names and unzip
disp('File prep')
[fmri_nii,mt1_nii,deffwd_nii,gray_nii,white_nii,csf_nii] = prep_files(inp);


%% Drop unwanted volumes
fprintf('Drop volumes from %s\n',fmri_nii);
dfmri_nii = drop_volumes(fmri_nii,inp.num_initial_vols_to_drop,inp.num_vols_to_analyze);


%% Find the TR
tr = get_tr(fmri_nii);


%% Slice timing correction
% Slice timing correction interpolates across time, possibly polluting high
% quality vols with artifact signal from nearby vols with high FD/DVARS
fprintf('Slice timing correction "%s" on %s\n',inp.slorder,dfmri_nii);
adfmri_nii = slice_timing_correction(dfmri_nii,tr,inp.slorder);


%% Realignment
fprintf('Realignment of %s\n',adfmri_nii);
[radfmri_nii,meanradfmri_nii,rp_txt] = realignment(adfmri_nii);


%% Make masked anat for coreg in T1 native space
[mmt1_nii,mask_nii] = mask_anat(mt1_nii,gray_nii,white_nii,csf_nii);


%% Coregister fmri to anat
fprintf('Coregister:\n    %s\n    %s\n',meanradfmri_nii,mmt1_nii)
[cradfmri_nii,cmeanradfmri_nii] = coregister( ...
	radfmri_nii,meanradfmri_nii,mmt1_nii);


%% Reslice images to native space post-realignment
ncradfmri_nii = reslice(cradfmri_nii,cmeanradfmri_nii);


%% Compute FD, DVARS
disp('Volume quality')
[FD,DVARS] = volume_quality(inp.out_dir,cmeanradfmri_nii,ncradfmri_nii,rp_txt);


%% Warp fMRI to MNI space
% Start with the registered, but un-resliced, images to minimize
% interpolation steps
fprintf('Warping:\n    %s\n    %s\n',cmeanradfmri_nii,cradfmri_nii);
wcmeanradfmri_nii = warp_images(deffwd_nii,cmeanradfmri_nii, ...
	mnigeom_nii,1,inp.out_dir);
wcradfmri_nii = warp_images(deffwd_nii,cradfmri_nii, ...
	mnigeom_nii,1,inp.out_dir);


%% Check registration
% First warp GM to high resolution space to get better edges
wgrayedge_nii = warp_images(deffwd_nii,gray_nii, ...
	[spm('dir') '/tpm/TPM.nii'],1,inp.out_dir);
wedge_nii = coreg_check(inp.out_dir,wcmeanradfmri_nii,wgrayedge_nii,0.5);


%% Process fMRI: filter, warp

disp('Filter')

% First warp gray matter to MNI for masking
wgray_nii = warp_images(deffwd_nii,gray_nii,mnigeom_nii,1,inp.out_dir);

% Remove gray matter signal, no scrub
[filtered_removegm_nii,confounds_removegm_txt] = connectivity_filter( ...
	inp.out_dir, ncradfmri_nii, rp_txt, gray_nii, white_nii, csf_nii, tr, ...
	inp.slorder, inp.num_initial_vols_to_drop, ...
	inp.bandpasslo_hz, inp.bandpasshi_hz, FD, DVARS, [], ...
	inp.mot_PCs, inp.motderiv_PCs, inp.wmcsf_PCs, ...
	1, inp.project, inp.subject, inp.session, [inp.scan ' Native'] ...
	);
wfiltered_removegm_nii = connectivity_filter_apply( ...
	inp.out_dir,wcradfmri_nii,wgray_nii,confounds_removegm_txt,'removegm_noscrub');


% Keep gray matter signal, no scrub
[filtered_keepgm_nii,confounds_keepgm_txt] = connectivity_filter( ...
	inp.out_dir, ncradfmri_nii, rp_txt, gray_nii, white_nii, csf_nii, tr, ...
	inp.slorder, inp.num_initial_vols_to_drop, ...
	inp.bandpasslo_hz, inp.bandpasshi_hz, FD, DVARS, [], ...
	inp.mot_PCs, inp.motderiv_PCs, inp.wmcsf_PCs, ...
	0, inp.project, inp.subject, inp.session, [inp.scan ' Native'] ...
	);
wfiltered_keepgm_nii = connectivity_filter_apply( ...
	inp.out_dir,wcradfmri_nii,wgray_nii,confounds_keepgm_txt,'keepgm_noscrub');



%% Make output PDF
% First warp mask to MNI for QA images
wmask_nii = warp_images(deffwd_nii,mask_nii,mnigeom_nii,0,inp.out_dir);

make_network_maps( ...
	inp.out_dir, ...
	wfiltered_removegm_nii, ...
	wcmeanradfmri_nii, ...
	wmask_nii, ...
	wedge_nii, ...
	inp.project, ...
	inp.subject, ...
	inp.session, ...
	inp.scan ...
	)

make_pdf(inp.out_dir,inp.magick_path);


%% Mask MNI space images to save space
mask_mni(inp.out_dir,{wfiltered_removegm_nii,wfiltered_keepgm_nii});


%% Zip output images
zip_outputs(inp.out_dir);


%% Exit
if isdeployed
	exit
end


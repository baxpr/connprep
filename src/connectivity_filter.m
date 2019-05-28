function filtered_fmri_nii = connectivity_filter( ...
	out_dir, ...
	fmri_nii, ...
	rp_txt, ...
	gray_nii, ...
	white_nii, ...
	csf_nii, ...
	tr, ...
	slorder, ...
	num_initial_vols_to_drop, ...
	num_vols_to_analyze, ...
	bandpasslo_hz, ...
	bandpasshi_hz, ...
	FD, ...
	DVARS, ...
	badvols, ...
	mot_PCs, ...
	motderiv_PCs, ...
	wmcsf_PCs, ...
	remove_gm, ...
	project, ...
	subject, ...
	session, ...
	scan ...
	)

% NOTE: tr is given in sec.
%
% Bandpass filter is implemented as a set of sine and cosine basis
% functions in the confound matrix.


%% Some things are strings
mot_PCs = str2double(mot_PCs);
motderiv_PCs = str2double(motderiv_PCs);
wmcsf_PCs = str2double(wmcsf_PCs);
bandpasslo_hz = str2double(bandpasslo_hz);
bandpasshi_hz = str2double(bandpasshi_hz);


%% Filename tag based on filtering params
if remove_gm==0 && isempty(badvols)
	filetag = 'keepgm_noscrub';
elseif remove_gm==0 && ~isempty(badvols)
	filetag = 'keepgm_scrub';
elseif remove_gm==1 && isempty(badvols)
	filetag = 'removegm_noscrub';
elseif remove_gm==1 && ~isempty(badvols)
	filetag = 'removegm_scrub';
end	


%% Motion and first differences regressors
rp = load(char(rp_txt));
if mot_PCs == 0
	fprintf('No motion removed\n')
	mot_regr = [];
elseif mot_PCs == 6
	fprintf('Remove 6 motion params\n')
	mot_regr = rp;
else
	fprintf('Remove %d motion PCs\n',mot_PCs);
	[~,P] = pca(zscore(rp));
	mot_regr = P(:,1:mot_PCs);
end

rp_delta = [zeros(1,6); diff(rp)];
if motderiv_PCs == 0
	fprintf('No motion derivs removed\n')
	motderiv_regr = [];
elseif motderiv_PCs == 6
	fprintf('Remove 6 motion derivs\n')
	motderiv_regr = rp_delta;
else
	fprintf('Remove %d motion deriv PCs\n',mot_PCs);
	[~,P] = pca(zscore(rp_delta));
	motderiv_regr = P(:,1:motderiv_PCs);
end


%% Resample the structural images to the fmri voxel geometry
flags = struct( ...
	'mask',true, ...
	'mean',false, ...
	'interp',1, ...
	'which',1, ...
	'wrap',[0 0 0], ...
	'prefix','r' ...
	);

spm_reslice({[fmri_nii ',1']; gray_nii},flags);
[p,n,e] = fileparts(gray_nii);
rgray_nii = fullfile(p,['r' n e]);

spm_reslice({[fmri_nii ',1']; white_nii},flags);
[p,n,e] = fileparts(white_nii);
rwhite_nii = fullfile(p,['r' n e]);

spm_reslice({[fmri_nii ',1']; csf_nii},flags);
[p,n,e] = fileparts(csf_nii);
rcsf_nii = fullfile(p,['r' n e]);


% Read images. Reshape fmri for time series processing
grayV = spm_vol(char(rgray_nii));
grayY = spm_read_vols(grayV);

whiteV = spm_vol(char(rwhite_nii));
whiteY = spm_read_vols(whiteV);

csfV = spm_vol(char(rcsf_nii));
csfY = spm_read_vols(csfV);

fmriV = spm_vol(char(fmri_nii));
fmriY = spm_read_vols(fmriV);
fmriY = reshape(fmriY,[],size(fmriY,4))';


% Define GM and WMCSF compartments and write to file
wmcsf_threshold = 0.98;
wmcsfY = (whiteY + csfY) >= wmcsf_threshold;
wmcsfV = whiteV;
wmcsfV.pinfo(1:2) = [1 0];
wmcsfV.fname = [out_dir filesep 'wmcsf_mask.nii'];
spm_write_vol(wmcsfV,wmcsfY);

gray_threshold = 0.5;
gmY = grayY >= gray_threshold;
gmV = grayV;
gmV.pinfo(1:2) = [1 0];
gmV.fname = [out_dir filesep 'gm_mask.nii'];
spm_write_vol(gmV,gmY);


% Erode WMCSF
%nhood = nan(3,3,3);
%nhood(:,:,1) = [0 0 0; 0 1 0; 0 0 0];
%nhood(:,:,2) = [0 1 0; 1 1 1; 0 1 0];
%nhood(:,:,3) = [0 0 0; 0 1 0; 0 0 0];
%erodeY = wmcsfY;
%erodeY = imerode(erodeY,nhood);
%erodeV = wcsegV;
%erodeV.pinfo(1:2) = [1 0];
%erodeV.fname = [out_dir '/wmcsf_eroded.nii'];
%spm_write_vol(erodeV,erodeY);

% Gray matter regressor
if remove_gm
	fprintf('Removing mean gray matter signal\n')
	gray_signals = fmriY(:,gmY(:)>0);
	gray_regr = mean(gray_signals,2);
else
	fprintf('NOT removing mean gray matter signal\n')
	gray_regr = [];
end

% WMCSF regressors 
wmcsf_signals = fmriY(:,wmcsfY(:)>0);
if wmcsf_PCs == 0
	fprintf('NOT removing white matter/CSF signal\n')
	wmcsf_regr = [];
elseif wmcsf_PCs == 1
	fprintf('Removing mean white matter/CSF signal\n')
	wmcsf_regr = mean(wmcsf_signals,2);
else
	fprintf('Removing %d PCs of white matter/CSF signal\n',wmcsf_PCs)
	[~,PC] = pca(zscore(wmcsf_signals));
	wmcsf_regr = PC(:,1:wmcsf_PCs);
end


%% Bandpass filter regressors
fprintf('Filtering, %f - %f Hz\n',bandpasslo_hz,bandpasshi_hz);
bp_regr = fourier_filter_basis( ...
	size(rp,1),tr,bandpasslo_hz,bandpasshi_hz);


%% Scrub regressors
badvol_regr = zeros(length(badvols),sum(badvols));
badinds = find(badvols);
fprintf('Scrubbing %d bad volumes\n',length(badinds));
for b = 1:length(badinds)
    badvol_regr(badinds(b),b) = 1;
end


%% Create and apply confound (filter) matrix

% Read unsmoothed images
fmriV = spm_vol(char(fmri_nii));
fmriY = spm_read_vols(fmriV);
o = size(fmriY);
fmriY = reshape(fmriY,[],o(4))';

% Scale image data to percent of global mean
meanfmri = mean(fmriY,1);
thresh = spm_antimode(meanfmri);
globalmean = mean(meanfmri(meanfmri>thresh));
fmriY = 100 * fmriY / globalmean;

% Build confound matrix
confounds = [ ...
    zscore(bp_regr) ...
    zscore(mot_regr) ...
    zscore(motderiv_regr) ...
	badvol_regr ...
    zscore(wmcsf_regr) ...
    zscore(gray_regr) ...
    ];
confound_matrix_file = fullfile(char(out_dir),['confounds_' filetag '.txt']);
save(confound_matrix_file,'confounds','-ascii')

% Regress out the confounds from the images
desmtx = [confounds ones(size(confounds,1),1)];
beta = lscov(desmtx, fmriY);
fmriYc = fmriY - desmtx * beta;

% In-brain R values for random sample of grey matter voxels with adequate
% fMRI signal
keeps = find(gmY(:)>0 & meanfmri(:)>thresh);
randkeeps = keeps(randperm(length(keeps),2500));
Rpre = ( corr(fmriY(:,randkeeps)) );
Rpost = ( corr(fmriYc(:,randkeeps)) );


% Write out the filtered unsmoothed images
fmriYc = reshape(fmriYc',o);
filtered_fmri_nii = fullfile(out_dir,['filtered_' filetag '.nii']);
for v = 1:numel(fmriV)
    thisV = rmfield(fmriV(v),'pinfo');
    thisV.dt(1) = spm_type('float32');
    thisV.fname = filtered_fmri_nii;
    spm_write_vol(thisV,fmriYc(:,:,:,v));
end


%% Save a stats file
statsstr = sprintf( ...
    [ ...
    'FD_median=%0.2f\n' ...
    'DVARS_median=%0.2f\n' ...
    'bandpass_lo=%0.3f Hz\n' ...
    'bandpass_hi=%0.3f Hz\n' ...
    'TR=%0.3f\n' ...
    'mot_PCs=%d\n' ...
    'motderiv_PCs=%d\n' ...
    'wmcsf_PCs=%d\n' ...
    'remove_gray=%d\n' ...
    'slorder=%s\n' ...
    'init_dropvols=%s\n' ...
	'analyzed_vols=%s\n' ...
	'scrubbed_vols=%d\n' ...
	'Final_DOF=%d\n' ...
    ], ...
    nanmedian(FD), nanmedian(DVARS), ...
	bandpasslo_hz, bandpasshi_hz, tr, ...
    mot_PCs, motderiv_PCs, ...
	wmcsf_PCs, remove_gm, ...
	slorder, num_initial_vols_to_drop, num_vols_to_analyze, ...
	sum(badvols), size(desmtx,1)-size(desmtx,2) );
f = fopen([out_dir '/stats_' filetag '.txt'],'wt');
fprintf(f,statsstr);
fclose(f);


%% We also generate a report for PDF:

% Figure out screen size so the figure will fit
ss = get(0,'screensize');
ssw = ss(3);
ssh = ss(4);
ratio = 8.5/11;
if ssw/ssh >= ratio
	dh = ssh;
	dw = ssh * ratio;
else
	dw = ssw;
	dh = ssw / ratio;
end

% Create figure
pdf_figure = openfig('pdf_connfilter_figure.fig','new');
set(pdf_figure,'Tag','pdf_connfilter');
set(pdf_figure,'Units','pixels','Position',[0 0 dw dh]);
figH = guihandles(pdf_figure);

% Summary
set(figH.summary_text, 'String', sprintf( ...
    [ ...
    'FD_median %0.2f\n' ...
    'DVARS_median %0.2f\n' ...
    'bandpass_lo %0.3f Hz\n' ...
    'bandpass_hi %0.3f Hz\n' ...
    'TR %0.3d s\n' ...
    'mot_PCs %d\n' ...
    'motderiv_PCs %d\n' ...
    'wmcsf_PCs %d\n' ...
    'remove_gray %d\n' ...
    'slorder %s\n' ...
    'init_dropvols %s\n' ...
	'analyzed_vols %s\n' ...
	'scrubbed_vols %d\n' ...
	'Final DOF %d\n' ...
    ], ...
    nanmedian(FD), nanmedian(DVARS), ...
	bandpasslo_hz, bandpasshi_hz, tr, ...
    mot_PCs, motderiv_PCs, ...
	wmcsf_PCs, remove_gm, ...
	slorder, num_initial_vols_to_drop, num_vols_to_analyze, ...
	sum(badvols), size(desmtx,1)-size(desmtx,2) ))

% Scan info
set(figH.scan_info, 'String', sprintf( ...
	'%s: %s, %s, %s, %s', ...
	filetag, project, subject, session, scan));
set(figH.date,'String',['Report date: ' date]);
set(figH.version,'String',['Matlab version: ' version]);


% Compute COM of image in each axis
fmriV = spm_vol([char(fmri_nii) ',1']);
fmriY = spm_read_vols(fmriV);
q3 = squeeze(nansum(nansum(fmriY,1),2));
fmricom3 = round(sum((1:length(q3))' .* q3) / sum(q3));

% Image slice
axes(figH.slice)
img = fmriY(:,:,fmricom3);
imagesc(imrotate(abs(img),90))
colormap(gray)
axis image
axis off
title('Raw image')

% GM mask
axes(figH.gm)
img = gmY(:,:,fmricom3);
imagesc(imrotate(abs(img),90))
colormap(gray)
axis image
axis off
title(sprintf('Grey (%0.0f%%)',100*gray_threshold))

% WM/CSF mask
axes(figH.wmcsf)
img = wmcsfY(:,:,fmricom3);
imagesc(imrotate(abs(img),90))
colormap(gray)
axis image
axis off
title(sprintf('WM/CSF (%0.0f%%)',100*wmcsf_threshold))

% FD
axes(figH.FD)
plot(FD,'b')
hold on
plot(find(badvols),FD(badvols),'ro')
title('Framewise Displacement (FD)')
set(gca,'XTick',[],'XLim',[0 length(FD)+1])

% DVARS
axes(figH.DVARS)
plot(DVARS,'b')
hold on
plot(find(badvols),DVARS(badvols),'ro')
title('Signal Change (DVARS)')
xlabel('Volume')
set(gca,'XLim',[0 length(DVARS)+1])

% Histogram plot
bins = -1:0.01:1;
Hpre = hist(Rpre(:),bins);
Hpost = hist(Rpost(:),bins);
axes(figH.histograms)
plot(bins,Hpre/length(Rpre(:)),'r')
hold on
plot(bins,Hpost/length(Rpost(:)),'b')
plot([0 0],get(gca,'Ylim'),':k')
legend({'Unfiltered' 'Filtered'},'Interpreter','None')
xlabel('Voxel-voxel correlation (R)')
ylabel('Frequency in random gray matter sample')

% Print to PNG
print(gcf,'-dpng',fullfile(out_dir,['connectivity_' filetag '.png']))
close(gcf);

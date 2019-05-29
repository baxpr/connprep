function make_network_maps( ...
	out_dir, ...
	wfiltered_fmri_nii, ...
	wmeanfmri_nii, ...
	mask_nii, ...
	edge_nii, ...
	project, ...
	subject, ...
	session, ...
	scan ...
	)

% Yeo parcellation
%    1  Visual
%    2  Somatomotor
%    3  Dorsal Attention
%    4  Ventral Attention
%    5  Limbic
%    6  Fronto-parietal
%    7  Default mode
% Copy, resample, load
copyfile( ...
	which('Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz'), ...
	fullfile(out_dir,'Yeo.nii.gz'));
system(['gunzip -f ' out_dir '/Yeo.nii.gz']);
yeo_nii = [out_dir '/Yeo.nii'];
flags = struct('mask',true,'mean',false,'interp',0,'which',1,'wrap',[0 0 0], ...
        'prefix','r');
spm_reslice({[wfiltered_fmri_nii ',1']; yeo_nii},flags);
[p,n,e] = fileparts(yeo_nii);
ryeo_nii = fullfile(p,['r' n e]);
Vyeo = spm_vol(ryeo_nii);
Yyeo = spm_read_vols(Vyeo);

% Resample the edge image for background and load
spm_reslice({[wfiltered_fmri_nii ',1']; edge_nii},flags);
[p,n,e] = fileparts(edge_nii);
redge_nii = fullfile(p,['r' n e]);
Vedge = spm_vol(redge_nii);
Yedge = spm_read_vols(Vedge);

% And for mask
spm_reslice({[wfiltered_fmri_nii ',1']; mask_nii},flags);
[p,n,e] = fileparts(mask_nii);
rmask_nii = fullfile(p,['r' n e]);
Vmask = spm_vol(rmask_nii);
Ymask = spm_read_vols(Vmask);
keeps = Ymask(:)>0;

% Load filtered fMRI data
Ymeanfmri = spm_read_vols(spm_vol(wmeanfmri_nii));
Yfmri = spm_read_vols(spm_vol(wfiltered_fmri_nii));
osize = size(Yfmri);
Yfmri = reshape(Yfmri,[],osize(4))';


% Extract time series for each system
warning('off','MATLAB:table:RowsAddedExistingVars')
systems = table([],cell(0,1),'VariableNames',{'Label','System'});
systems.Label(end+1,1) = 1; systems.System{end,1} = 'Visual';
systems.Label(end+1,1) = 2; systems.System{end,1} = 'Somatomotor';
systems.Label(end+1,1) = 3; systems.System{end,1} = 'DorsalAttention';
systems.Label(end+1,1) = 4; systems.System{end,1} = 'VentralAttention';
systems.Label(end+1,1) = 5; systems.System{end,1} = 'Limbic';
systems.Label(end+1,1) = 6; systems.System{end,1} = 'FrontoParietal';
systems.Label(end+1,1) = 7; systems.System{end,1} = 'DefaultMode';

maps = zeros(height(systems),length(Ymeanfmri(:)));
for sy = 1:height(systems)
	
	roidata = Yfmri(:,Ymask(:) & Yyeo(:)==systems.Label(sy));
	roimean = mean(roidata,2);
	maps(sy,keeps) = corr(roimean,Yfmri(:,keeps));
	
	% Threshold at +/- 10th percentile
	% Add the edge image at a weird place that will be mapped to black in
	% the colormap
	p = prctile(maps(sy,keeps),[10,90]);
	maps(sy, maps(sy,:)>p(1) & maps(sy,:)<p(2) ) = 0;
	maps(sy, maps(sy,:)==0   & Yedge(:)'>0    ) = 0.0864;
	
end

msize = [osize(1:3) height(systems)];
maps = reshape(maps',msize);

% PDF figures

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

for sy = 1:height(systems)
	
	% Create figure
	pdf_figure = openfig('pdf_connmaps_figure.fig','new');
	set(pdf_figure,'Tag','pdf_connmaps');
	set(pdf_figure,'Units','pixels','Position',[0 0 dw dh]);
	figH = guihandles(pdf_figure);
	
	% Summary
	set(figH.summary_text, 'String', ...
		sprintf('%s',systems.System{sy}) )
	
	% Scan info
	set(figH.scan_info, 'String', sprintf( ...
		'%s, %s, %s, %s', ...
		project, subject, session, scan));
	set(figH.date,'String',['Report date: ' date]);
	set(figH.version,'String',['Matlab version: ' version]);
	
	% Custom colormap:
	%    1       21       41        61      81
	%    cyan    blue    (black)   red     yellow
	%    0 1 1   0 0 1   (0 0 0)   1 0 0   1 1 0
	cmap = zeros(81,3);
	cmap(1:21,2) = 1:-1/20:0;
	cmap(1:21,3) = 1;
	cmap(21:41,3) = 1:-1/20:0;
	cmap(41:61,1) = 0:1/20:1;
	cmap(61:81,2) = 0:1/20:1;
	cmap(61:81,1) = 1;
	cmap(40:42,:) = 1;
	set(pdf_figure,'Colormap',cmap);
	
	% Slices
	ns = size(Ymeanfmri,3);
	ss = round(20 : (ns-30)/9 : ns-10);
	for sl = 1:9
		ax = ['slice' num2str(sl)];
		axes(figH.(ax))
		imagesc(imrotate(maps(:,:,ss(sl),sy),90),[-1 1])
		axis image off
	end
	
	% Print to PNG
	print(gcf,'-dpng',sprintf('%s/connmap_%s.png',out_dir,systems.System{sy}))
	close(pdf_figure)
	
end



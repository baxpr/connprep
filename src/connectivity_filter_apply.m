function filtered_fmri_nii = connectivity_filter_apply( ...
	out_dir,fmri_nii,gray_nii,confounds_txt,filetag)

% Read unsmoothed images
fmriV = spm_vol(char(fmri_nii));
fmriY = spm_read_vols(fmriV);
o = size(fmriY);
fmriY = reshape(fmriY,[],o(4))';

% Scale mean gray matter value to 100
grayV = spm_vol(gray_nii);
grayY = spm_read_vols(grayV);
meanfmri = mean(fmriY,1);
globalmean = mean( meanfmri(:).*grayY(:) / sum(grayY(:)) );
fmriY = 100 * fmriY / globalmean;

% Regress out the confounds from the images
confounds = load(confounds_txt);
desmtx = [confounds ones(size(confounds,1),1)];
beta = lscov(desmtx, fmriY);
fmriYc = fmriY - desmtx * beta;

% Write out the filtered unsmoothed images
fmriYc = reshape(fmriYc',o);
[~,n,e] = fileparts(fmri_nii);
filtered_fmri_nii = fullfile(out_dir,['filtered_' filetag '_' n e]);
for v = 1:numel(fmriV)
    thisV = rmfield(fmriV(v),'pinfo');
    thisV.dt(1) = spm_type('float32');
    thisV.fname = filtered_fmri_nii;
    spm_write_vol(thisV,fmriYc(:,:,:,v));
end


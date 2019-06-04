function mask_mni(fmri_niis)

for f = 1:length(fmri_niis)

	fmri_nii = fmri_niis{f};

	% Resample ICV to fMRI space and load
	flags = struct('mask',true,'mean',false,'interp',0,'which',1, ...
        'wrap',[0 0 0],'prefix','r');
	icv_nii = [spm('dir') '/tpm/mask_ICV.nii'];
	spm_reslice({[fmri_nii ',1'],icv_nii},flags);
	[p,n,e] = fileparts(icv_nii);
	ricv_nii = fullfile(p,['r' n e]);
	Vicv = spm_vol(ricv_nii);
	Yicv = spm_read_vols(Vicv);
	
	% Dilate
	Yicv = imdilate(Yicv,strel('sphere',10));
	spm_write_vol(Vicv,Yicv);
	
	% Mask fMRI and save, volume by volume
	Vfmri = spm_vol(fmri_nii);
	Yfmri = spm_read_vols(Vfmri);
	for v = 1:size(Yfmri,4)
		tmp = Yfmri(:,:,:,v);
		tmp(Yicv(:)==0) = nan;
		spm_write_vol(Vfmri(v),tmp);
	end	
	
end

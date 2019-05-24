function afmri_nii = slice_timing_correction(fmri_nii,tr,slorder)
% Slice timing correction module for connectivity preproc spider. Slice
% timing correction is applied in the third dimension (Z, often axial).

% Number of slices
V = spm_vol(fmri_nii);
nslices = V(1).dim(3);

% Slice order
switch slorder
	
	case 'ascending'
		slorder = 1:nslices;
		
	case 'descending'
		slorder = nslices:-1:1;

	case 'ascending_interleaved'
		slorder = [1:2:nslices 2:2:nslices];
		
	case 'descending_interleaved'
		slorder = [nslices:-2:1 (nslices-1):-2:1];

	case 'none'
		[fmri_p,fmri_n,fmri_e] = fileparts(fmri_nii);
		afmri_nii = fullfile(fmri_p,['a' fmri_n fmri_e]);
		copyfile(fmri_nii,afmri_nii);
		return
		
	otherwise
		error('Unknown slice order')
		
end

% Call the SPM routine
ta = tr - tr/nslices;
spm_slice_timing(fmri_nii,slorder,1,[ta/nslices-1 tr-ta],'a');

% Filename for slice time corrected images
[fmri_p,fmri_n,fmri_e] = fileparts(fmri_nii);
afmri_nii = fullfile(fmri_p,['a' fmri_n fmri_e]);


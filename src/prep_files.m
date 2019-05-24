function [fmri_nii,mt1_nii,deffwd_nii,gray_nii,white_nii,csf_nii] = prep_files( ...
	out_dir,fmri_niigz,mt1_niigz,deffwd_niigz,gray_niigz,white_niigz,csf_niigz)

copyfile(fmri_niigz,[out_dir '/fmri.nii.gz']);
system(['gunzip -f ' out_dir '/fmri.nii.gz']);
fmri_nii = [out_dir '/fmri.nii'];

copyfile(mt1_niigz,[out_dir '/mt1.nii.gz']);
system(['gunzip -f ' out_dir '/mt1.nii.gz']);
mt1_nii = [out_dir '/mt1.nii'];

copyfile(deffwd_niigz,[out_dir '/y_deffwd.nii.gz']);
system(['gunzip -f ' out_dir '/y_deffwd.nii.gz']);
deffwd_nii = [out_dir '/y_deffwd.nii'];

copyfile(gray_niigz,[out_dir '/gray.nii.gz']);
system(['gunzip -f ' out_dir '/gray.nii.gz']);
gray_nii = [out_dir '/gray.nii'];

copyfile(white_niigz,[out_dir '/white.nii.gz']);
system(['gunzip -f ' out_dir '/white.nii.gz']);
white_nii = [out_dir '/white.nii'];

copyfile(csf_niigz,[out_dir '/csf.nii.gz']);
system(['gunzip -f ' out_dir '/csf.nii.gz']);
csf_nii = [out_dir '/csf.nii'];

function [fmri_nii,mt1_nii,deffwd_nii,gray_nii,white_nii,csf_nii] = ...
	prep_files(inp)

copyfile(inp.fmri_niigz,[inp.out_dir '/fmri.nii.gz']);
system(['gunzip -f ' inp.out_dir '/fmri.nii.gz']);
fmri_nii = [inp.out_dir '/fmri.nii'];

copyfile(inp.mt1_niigz,[inp.out_dir '/mt1.nii.gz']);
system(['gunzip -f ' inp.out_dir '/mt1.nii.gz']);
mt1_nii = [inp.out_dir '/mt1.nii'];

copyfile(inp.deffwd_niigz,[inp.out_dir '/y_deffwd.nii.gz']);
system(['gunzip -f ' inp.out_dir '/y_deffwd.nii.gz']);
deffwd_nii = [inp.out_dir '/y_deffwd.nii'];

copyfile(inp.gray_niigz,[inp.out_dir '/gray.nii.gz']);
system(['gunzip -f ' inp.out_dir '/gray.nii.gz']);
gray_nii = [inp.out_dir '/gray.nii'];

copyfile(inp.white_niigz,[inp.out_dir '/white.nii.gz']);
system(['gunzip -f ' inp.out_dir '/white.nii.gz']);
white_nii = [inp.out_dir '/white.nii'];

copyfile(inp.csf_niigz,[inp.out_dir '/csf.nii.gz']);
system(['gunzip -f ' inp.out_dir '/csf.nii.gz']);
csf_nii = [inp.out_dir '/csf.nii'];

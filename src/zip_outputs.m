function zip_outputs(out_dir)

% Zip images
system(['cd ' out_dir ' && gzip -f *.nii']);

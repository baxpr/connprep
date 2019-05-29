function edge_nii = coreg_check( ...
	out_dir, ...
	bkgnd_file, ...
	overlay_file, ...
	threshold ...
    )

% Make a nice at-a-glance image to check registration between structural
% and functional. Works great with the mean functional as the background
% and the gray matter segmented image as the overlay. Most consistent for
% checking if the MNI space versions are used.
%
% Dependencies:
%     canny  (http://www.mathworks.com/matlabcentral/fileexchange/45459-canny-edge-detection-in-2-d-and-3-d)
%
% Outputs:
%     edge image
%     png graphic

% Edge image filename
[~,n,e] = fileparts(overlay_file);
edge_nii = fullfile(out_dir,['edge_' n e]);

% Smooth and load the anat image
Vover = spm_vol(overlay_file);
spm_smooth(Vover,[out_dir '/smover.nii'],[4 4 4]);
Vover = spm_vol([out_dir '/smover.nii']);
Yover = spm_read_vols(Vover);
if ~isempty(threshold)
	Yover = double(Yover > threshold);
end

% Compute the edge image and save
Yedge = canny(Yover);
Vedge = rmfield(Vover,'pinfo');
Vedge.fname = edge_nii;
spm_write_vol(Vedge,Yedge);


% Show the functional image
spm_check_registration(bkgnd_file);

% Overlay the anat edge image
spm_orthviews('Xhairs','off');
spm_orthviews('addcolouredimage',1,edge_nii,[1 0 0]);
spm_orthviews('Reposition',[6 0 0]);

% Print
print(gcf,'-dpng',fullfile(out_dir,'coreg_check.png'))

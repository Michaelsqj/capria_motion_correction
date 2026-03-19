fname='/vols/Data/okell/qijia/perf_recon_30-11-23/scan_3/mpr_anat';
[img, ~, scales, ~, ~] =  read_avw(fname);
new_img = img(end:-1:1, end:-1:1, :);
save_avw(new_img, [fname '_flip'], 'd', scales);

system(['module load freesurfer;mri_synthseg --i ' fname '_flip.nii.gz --o ' fname '_flip_seg.nii.gz']);

% merge the segmentation
% Gray Matter (GM):
% 3, 8, 10, 11, 12, 13, 17, 18, 26, 28, 42, 47, 49, 50, 51, 52, 53, 54, 58, 60

% White Matter (WM):
% 2, 7, 41, 46

% Cerebrospinal Fluid (CSF):
% 4, 5, 14, 15, 24, 43, 44

new_seg = read_avw([fname '_flip_seg.nii.gz']);
gm_labels = [3, 8, 10, 11, 12, 13, 17, 18, 26, 28, 42, 47, 49, 50, 51, 52, 53, 54, 58, 60];
wm_labels = [2, 7, 41, 46];
csf_labels = [4, 5, 14, 15, 24, 43, 44];
seg = zeros(size(new_seg));
for ii = unique(new_seg(:))'
    if ismember(ii, gm_labels)
        disp(ii)
        disp('gm')
        seg(new_seg == ii) = 1;
    elseif ismember(ii, wm_labels)
        disp(ii)
        disp('wm')
        seg(new_seg == ii) = 2;
    elseif ismember(ii, csf_labels)
        disp(ii)
        disp('csf')
        seg(new_seg == ii) = 3;
    end
end

seg = seg(end:-1:1, end:-1:1, :);
save_avw(seg, [fname '_seg'], 'd', [1,1,1]);
cmd=['applywarp -i ' fname '_seg.nii.gz -r ' fname ' -o ' fname '_seg_lr --super --interp=nn'];
disp(cmd);
system(cmd);
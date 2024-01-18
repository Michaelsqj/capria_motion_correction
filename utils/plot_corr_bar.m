img1_fpaths=["/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_stage2_combined.nii.gz"...
    "/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_stage1_gridding.nii.gz"...
    "/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_stage1_combined.nii.gz",...
]
img2_fpath="/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_gt.nii.gz"
mask_fpath='/vols/Data/okell/qijia/perf_recon_6-11-23/meas_MID00133_FID35121_qijia_CV_VEPCASL_WE_fullsphere_johnson_60_100hz_anat1tmp_brain_mask.nii.gz'
for ii=1:length(img1_fpaths)
    r(:,ii) = correlation(char(img1_fpaths(ii)),char(img2_fpath),mask_fpath);
end
%%
bar(r)
% turn off the xtick
set(gca,'XTick',[])
% turn off the xtick label
set(gca,'XTickLabel',[])
% set font size to 20
set(gca,'FontSize',16)
% turn off box
set(gca,'box','off')
saveas(gcf,'tmp.png','png')
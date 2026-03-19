PYTHONCMD="${HOME}/scratch/conda/envs/pytorch/bin/python"
plot_code="/home/fs0/qijia/code/moco/utils/plot_figs.py"
output_path="/home/fs0/qijia/code/moco/utils/plots/"


# "15-11-23" "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"
date="7-12-23"
ind=3
perf_recon_path="/vols/Data/okell/qijia/perf_recon_${date}"
subfolder="scan_${ind}"
fname="${perf_recon_path}/${subfolder}/perfusion_gt.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png --troi=4,5\
    --vrange=0,0.3 --xroi=2,60 --yroi=3,63 --zroi=2,48 --show_axis=y,z --outname=${output_path}/perfusion_gt"
eval $CMD
fname="${perf_recon_path}/${subfolder}/perfusion_stage3.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png --troi=4,5\
    --vrange=0,0.5 --xroi=2,60 --yroi=3,63 --zroi=2,48 --show_axis=y,z --outname=${output_path}/perfusion_stage3"
# echo $CMD
eval $CMD
fname="${perf_recon_path}/${subfolder}/perfusion_stage3_match.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png --troi=3,4\
    --vrange=0,0.5 --xroi=2,60 --yroi=3,63 --zroi=2,48 --show_axis=y,z --outname=${output_path}/perfusion_stage3_match"
# eval $CMD
fname="${perf_recon_path}/${subfolder}/sens0.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png\
    --vrange=0,1 --show_axis=z --outname=${output_path}/sens0"
# eval $CMD

ind=3
subfolder="scan_${ind}"
fname="${perf_recon_path}/${subfolder}/perfusion_gt.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png --troi=3,4\
    --vrange=0,0.3 --xroi=2,60 --yroi=3,63 --zroi=2,48 --show_axis=y,z --outname=${output_path}/perfusion_stage3_gt"
# eval $CMD


# perf_recon_path="/vols/Data/okell/qijia/perf_recon_${date}"
# subfolder="scan_${ind}"
fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_gt.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png --troi=4,5\
    --vrange=0,0.6 --xroi=2,60 --yroi=3,63 --zroi=2,48 --show_axis=y,z --outname=${output_path}/perfusion_gt"
# eval $CMD
# fname="${perf_recon_path}/scan_4/perfusion_stage3.nii.gz"
# fname="/vols/Data/okell/qijia/perf_recon_16-2-23/meas_MID00127_FID05979_qijia_CV_VEPCASL_halfg_johnson_60_1_3_500_24x48_100hz_176_vFA_diff_LLR_avg1-0.1-5_1.nii.gz"
fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_stage2_combined.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png --troi=4,5\
    --vrange=0,0.7 --xroi=2,60 --yroi=3,63 --zroi=2,48 --show_axis=y,z --outname=${output_path}/perfusion_stage2_combined"
# eval $CMD
fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_stage2_combined_reg2gt.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png --troi=4,5\
    --vrange=0,0.7 --xroi=2,60 --yroi=3,63 --zroi=2,48 --show_axis=y,z --outname=${output_path}/perfusion_stage2_combined_reg2gt"
# eval $CMD
fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_stage0.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png --troi=4,5\
    --vrange=0,0.7 --xroi=2,60 --yroi=3,63 --zroi=2,48 --show_axis=y,z --outname=${output_path}/perfusion_stage0"
# eval $CMD
fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_stage1_gridding.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png --troi=4,5\
    --vrange=0,0.7 --xroi=2,60 --yroi=3,63 --zroi=2,48 --show_axis=y,z --outname=${output_path}/perfusion_stage1_gridding"
# eval $CMD
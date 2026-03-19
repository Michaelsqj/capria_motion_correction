PYTHONCMD="${HOME}/scratch/conda/envs/pytorch/bin/python"
plot_code="/home/fs0/qijia/code/moco/utils/plot_figs.py"
output_path="/home/fs0/qijia/code/moco/utils/plots/"

# 1. plot angiogram, capria, before correction
# "15-11-23" "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"
# date="29-11-23"
# ind=1
# recon_path="/vols/Data/okell/qijia/recon_${date}"
# # perf_recon_path="/vols/Data/okell/qijia/perf_recon_${date}"
# subfolder="scan_${ind}"
# fname="${recon_path}/${subfolder}/struct_stage3.mat"
# CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --subspace --filetype=png --troi=65\
#     --vrange=0,1 --outname=${output_path}/struct_stage3"
# eval $CMD
# fname="${recon_path}/${subfolder}/struct_gt.mat"
# CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --subspace --filetype=png --troi=65\
#     --vrange=0,1 --outname=${output_path}/struct_gt"
# eval $CMD

# ind=3
# subfolder="scan_${ind}"
# fname="${recon_path}/${subfolder}/mpr_anat.nii.gz"
# CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png\
#     --vrange=0,1 --outname=${output_path}/mpr_anat"
# eval $CMD


# fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_gt_L_3_1e-7.mat"
# CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --subspace --filetype=png --troi=12,24,36,64,80,120 \
#     --vrange=0,1 --xroi=18,171"

# # 3. plot structural data, subspace
# fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_gt_L_3_1e-7.mat"
# CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --subspace --filetype=png --troi=12,16,20,24,28,32,36,40,44,48,52,56,60 \
#     --vrange=0,1 "
# eval $CMD
fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_gt_L_3_1e-7.mat"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --subspace --filetype=png --troi=12,36,60,84,108,132 \
    --vrange=0,1 "
eval $CMD
fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_gt_llr_nshots2.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png\
    --vrange=0,0.8 "
# eval $CMD
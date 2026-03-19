PYTHONCMD="${HOME}/scratch/conda/envs/pytorch/bin/python"
plot_code="/home/fs0/qijia/code/moco/utils/plot_figs.py"
output_path="/home/fs0/qijia/code/moco/utils/plots/"

# 1. plot angiogram, capria, before correction
# "15-11-23" "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"
date="7-12-23"
ind=1
recon_path="/vols/Data/okell/qijia/recon_${date}"
# perf_recon_path="/vols/Data/okell/qijia/perf_recon_${date}"
subfolder="scan_${ind}"
fname="${recon_path}/${subfolder}/angio_stage3.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --mip --filetype=png --troi=2,4\
    --vrange=0,0.4 --xroi=18,171 --yroi=25,186 --zroi=10,130 --show_axis=x,z --outname=${output_path}/angio_stage3"
eval $CMD
fname="${recon_path}/${subfolder}/angio_gt.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --mip --filetype=png --troi=2,4\
    --vrange=0,0.4 --xroi=18,171 --yroi=25,186 --zroi=10,130 --show_axis=x,z --outname=${output_path}/angio_gt"
eval $CMD

ind=3
subfolder="scan_${ind}"
fname="${recon_path}/${subfolder}/angio_stage3.nii.gz"
# fname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/meas_cone_144_capria_12.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --mip --filetype=png --troi=2,4\
    --vrange=0,0.4 --xroi=18,171 --yroi=25,186 --zroi=10,130 --show_axis=x,z --outname=${output_path}/angio_stage3_gt"
eval $CMD
# 2. plot angiogram, capria, after correction
PYTHONCMD="${HOME}/scratch/conda/envs/pytorch/bin/python"
plot_code="/home/fs0/qijia/code/moco/utils/plot_figs.py"


# 1. plot angiogram, subspace,  [186,196,150];
fname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/meas_cone_144_subspace_Nt144_Nk12_randomdict_L_balance_0_lambda_0.0005.mat"
# fname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/radial/meas_radial_144_subspace_Nt144_Nk12_randomdict_L_balance_0_lambda_0.0003.mat"
CMD="${PYTHONCMD} ${plot_code} --mip --fname=${fname} --axis=0 --filetype=png --subspace --troi=65\
      --vrange=0,0.4 --xroi=18,171 --yroi=20,176 --zroi=0,140"
# eval $CMD

# 1. plot angiogram, capria,  [186,196,150];
# fname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/meas_cone_144_capria_12.nii.gz"
fname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/radial/meas_radial_144_capria_12.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --mip --fname=${fname} --axis=0 --filetype=png  --troi=5\
      --vrange=0,0.2 --xroi=18,171 --yroi=20,176 --zroi=0,140"
eval $CMD
fname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/meas_cone_144_subspace_Nt144_Nk12_randomdict_L_balance_0_lambda_0.0005_AngioFitting/fabber_out/vessel_sig_1.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --mip --fname=${fname} --axis=1 --filetype=mp4\
      --vrange=0,0.8"
# eval $CMD
# 2. plot 

# 2. plot perfusion
# fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_stage0.nii.gz"
# "15-11-23" "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"

date="1-12-23_2"
ind=1
recon_path="/vols/Data/okell/qijia/recon_${date}"
perf_recon_path="/vols/Data/okell/qijia/perf_recon_${date}"
subfolder="scan_${ind}"
# fname="${perf_recon_path}/${subfolder}/perfusion_stage3.nii.gz"
fname="${perf_recon_path}/${subfolder}/perfusion_gt.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --filetype=png --troi=0,1,2,3,4,5\
    --vrange=0,0.4"
# eval $CMD

# angiogram 
fname="${recon_path}/${subfolder}/angio_stage3.nii.gz"
# fname="${recon_path}/${subfolder}/angio_gt.nii.gz"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --mip --filetype=png --troi=0,2,4,6,8,10\
    --vrange=0,0.8 --xroi=18,171 --yroi=30,186 --zroi=10,135"
# eval $CMD

# fname="${recon_path}/${subfolder}/struct_stage3.mat"
fname="${recon_path}/${subfolder}/struct_gt.mat"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --subspace --filetype=png --troi=86\
    --vrange=0,1"
# eval $CMD


# 3. plot structural data, subspace
fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_gt_L_3_1e-7.mat"
CMD="${PYTHONCMD} ${plot_code} --fname=${fname} --axis=0 --subspace --filetype=png --troi=12,24,36,64,80,120 \
    --vrange=0,1 --xroi=18,171"

# 4. plot parameter maps
# fname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/meas_cone_144_subspace_Nt144_Nk12_randomdict_L_balance_0_lambda_0.0005_AngioFitting/fabber_out/"
fname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/radial/meas_radial_144_subspace_Nt144_Nk12_randomdict_L_balance_0_lambda_0.0005_AngioFitting/fabber_out/"
# maskname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/mask_clusters_bin.nii.gz"
maskname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/radial/meas_radial_144_capria_12_AngioFitting/mask_clusters_bin.nii.gz"
plot_code="/home/fs0/qijia/code/moco/utils/paramap.py"
# CMD="${PYTHONCMD} ${plot_code} --mip --fname=${fname}/mean_deltblood.nii.gz --axis=0 --filetype=png  \
#     --vrange=1e-3,1.8 --xroi=18,171 --yroi=20,176 --zroi=10,130 --cmap=actc.cmap --mask=${maskname}"
# CMD="${PYTHONCMD} ${plot_code} --mip --fname=${fname}/mean_disp_p.nii.gz --axis=0 --filetype=png  \
#     --vrange=0,0.5 --xroi=18,171 --yroi=20,176 --zroi=10,130 --cmap=6bluegrn.cmap --mask=${maskname}"
CMD="${PYTHONCMD} ${plot_code} --mip --fname=${fname}/mean_disp_s.nii.gz --axis=0 --filetype=png  \
    --vrange=1,10 --xroi=18,171 --yroi=20,176 --zroi=10,130 --cmap=6bluegrn.cmap --mask=${maskname}"
# eval $CMD

# fname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/meas_cone_144_capria_12_AngioFitting/fabber_out/"
fname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/radial/meas_radial_144_capria_12_AngioFitting/fabber_out/"
# maskname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/mask_clusters_bin.nii.gz"
# maskname="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/radial/mask_clusters_bin.nii.gz"
plot_code="/home/fs0/qijia/code/moco/utils/paramap.py"
CMD="${PYTHONCMD} ${plot_code} --mip --fname=${fname}/mean_deltblood.nii.gz --axis=0 --filetype=png  \
    --vrange=1e-3,1.8 --xroi=18,171 --yroi=20,176 --zroi=10,130 --cmap=actc.cmap --mask=${maskname}"
CMD="${PYTHONCMD} ${plot_code} --mip --fname=${fname}/mean_disp_p.nii.gz --axis=0 --filetype=png  \
    --vrange=0,0.5 --xroi=18,171 --yroi=20,176 --zroi=10,130 --cmap=6bluegrn.cmap --mask=${maskname}"
CMD="${PYTHONCMD} ${plot_code} --mip --fname=${fname}/mean_disp_s.nii.gz --axis=0 --filetype=png  \
    --vrange=1,10 --xroi=18,171 --yroi=20,176 --zroi=10,130 --cmap=6bluegrn.cmap --mask=${maskname}"
# eval $CMD
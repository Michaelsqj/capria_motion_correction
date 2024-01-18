MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_1/angio_param_gt.m\'\)"
# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_1/angio_param_stage3_nomismatch.m\'\)"
# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_1/angio_param_stage3_pogm_split.m\'\)"
# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_1/struct_param_gt.m\'\)"
# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_1/struct_param_stage3.m\'\)"

# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_2/angio_param_gt.m\'\)"
# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_2/angio_param_stage3_nomismatch.m\'\)"
# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_2/angio_param_stage3_pogm_split.m\'\)"
# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_2/struct_param_gt.m\'\)"
# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_2/struct_param_stage3.m\'\)"

# fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_3/angio_param_gt.m\'\)"
fsl_sub -q short.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_param_stage1_combined_brain.m\'\)"
# fsl_sub -q short.q -s openmp,12 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/perfusion_param_stage2.m\'\)"
# fsl_sub -q bigmem.q -s openmp,1 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_3/struct_param_gt.m\'\)"
# fsl_sub -q bigmem.q -s openmp,1 -l logs ${MATLABCMD} "sim_invivo_motion\(\'/vols/Data/okell/qijia/recon_23-11-23/scan_3/struct_param_stage3.m\'\)"
# rm submit_script
# echo "${MATLABCMD} \"sim_invivo_motion('/vols/Data/okell/qijia/perf_recon_23-11-23/scan_1/perfusion_param_stage3.m')\"" >> submit_script
# echo "${MATLABCMD} \"sim_invivo_motion('/vols/Data/okell/qijia/perf_recon_23-11-23/scan_2/perfusion_param_stage3.m')\"" >> submit_script
# echo "${MATLABCMD} \"sim_invivo_motion('/vols/Data/okell/qijia/perf_recon_23-11-23/scan_3/perfusion_param_stage3.m')\"" >> submit_script
# echo "${MATLABCMD} \"sim_invivo_motion('/vols/Data/okell/qijia/perf_recon_23-11-23/scan_1/perfusion_param_gt.m')\"" >> submit_script
# echo "${MATLABCMD} \"sim_invivo_motion('/vols/Data/okell/qijia/perf_recon_23-11-23/scan_2/perfusion_param_gt.m')\"" >> submit_script
# echo "${MATLABCMD} \"sim_invivo_motion('/vols/Data/okell/qijia/perf_recon_23-11-23/scan_3/perfusion_param_gt.m')\"" >> submit_script

# CMD="$FSLSUBCMD -q short.q -s openmp,8 -t submit_script"
# ID=$(eval $CMD)
# Define the parameters for the reconstruction pipeline
module load fsl
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
if [ -f "/opt/fmrib/MATLAB/R2021a/bin/matlab" ]; then
    MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
else
    MATLABCMD="/cvmfs/matlab.fmrib.ox.ac.uk/MATLAB/R2023b/bin/matlab -nojvm -nodisplay -r"
fi
# MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"

code_path="/home/fs0/qijia/code/moco/"
# date: "15-11-23" "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"
# date="28-11-23"
for date in "1-12-23_2" "28-11-23"
do
    perf_recon_path="/vols/Data/okell/qijia/perf_recon_${date}"
    recon_path="/vols/Data/okell/qijia/recon_${date}"
    ind=2
    subfolder="scan_${ind}"
    # rm ${perf_recon_path}/${subfolder}/recon_struct_script
    # # reconstruct perfusion struct using llr
    # paramfname="${code_path}/example_scripts/struct_perfusion_param_gt.m"
    # SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p);"
    # echo $MATLABCMD \"$SUBCMD\" > ${perf_recon_path}/${subfolder}/recon_struct_script
    # CMD="$FSLSUBCMD -q short -s openmp,12 -t ${perf_recon_path}/${subfolder}/recon_struct_script"
    # ID=$(eval $CMD)

    # reconstruct struct using llr
    # rm ${recon_path}/${subfolder}/recon_struct_script
    # paramfname="${code_path}/example_scripts/struct_param_gt.m"
    # SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p);"
    # echo $MATLABCMD \"$SUBCMD\" > ${recon_path}/${subfolder}/recon_struct_script

    mcf_mat="${perf_recon_path}/scan_${ind}/subspace_stage1_gridding_mcf.mat"
    paramfname="${code_path}/example_scripts/perfusion_param_stage3_match.m"
    SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
    echo $MATLABCMD \"$SUBCMD\" > ${perf_recon_path}/${subfolder}/recon_perf_script3

    mcf_mat="${perf_recon_path}/scan_${ind}/subspace_stage1_gridding_mcf.mat"
    paramfname="${code_path}/example_scripts/perfusion_param_stage3_sub.m"
    SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
    echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/${subfolder}/recon_perf_script3

    CMD="$FSLSUBCMD -q short -s openmp,8 -t ${perf_recon_path}/${subfolder}/recon_perf_script3"
    ID=$(eval $CMD)
done
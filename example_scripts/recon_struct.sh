# Define the parameters for the reconstruction pipeline
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
code_path="/home/fs0/qijia/code/moco/"
# date: "15-11-23" "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"
# date="28-11-23"
for date in "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"
do
    ind=3
    subfolder="scan_${ind}"
    rm ${recon_path}/${subfolder}/recon_struct_script
    # reconstruct struct using subspace
    paramfname="${code_path}/example_scripts/struct_param_gt_subspace.m"
    SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p);"
    echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_struct_script
    # reconstruct struct using llr
    paramfname="${code_path}/example_scripts/struct_param_gt.m"
    SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p);"
    echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_struct_script

    CMD="$FSLSUBCMD -q short.q -s openmp,12 -t recon_struct_script"
    ID=$(eval $CMD)
done
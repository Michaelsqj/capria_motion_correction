# Define the parameters for the reconstruction pipeline
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
# if hostname starts with clcpu then
if [[ $(hostname) == clcpu* ]]; then
    MATLABCMD="/cvmfs/matlab.fmrib.ox.ac.uk/MATLAB/R2023b/bin/matlab -batch"
elif [[ $(hostname) == jalapeno* ]]; then
    # else if hostname starts with jalapeno then
    MATLABCMD="/opt/fmrib/MATLAB/R2023a/bin/matlab -batch"
fi
code_path="/home/fs0/qijia/code/moco/"
# 4. subspace reconstruct stage1 for scan_1 and scan_2
date="30-11-23"
raw_data_path="/vols/Data/okell/qijia/raw_data_${date}"
recon_path="/vols/Data/okell/qijia/recon_${date}"
perf_recon_path="/vols/Data/okell/qijia/perf_recon_${date}"
ind=2
subfolder="scan_${ind}"

paramfname="${code_path}/example_scripts/subspace_param_stage2.m"
# 4.1. parallel subspace recon
rm ${perf_recon_path}/${subfolder}/recon_subspace_coef_script_n2
for i in {1..98}
do
    SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};p.shot_ind=${i};sim_invivo_motion('${paramfname}',p)"
    echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/${subfolder}/recon_subspace_coef_script_n2
done

CMD="$FSLSUBCMD -q short.q -s openmp,4 -t ${perf_recon_path}/${subfolder}/recon_subspace_coef_script_n2"
echo $CMD
ID=$(eval $CMD)



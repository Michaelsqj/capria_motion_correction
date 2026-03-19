# Define the parameters for the reconstruction pipeline
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
code_path="/home/fs0/qijia/code/moco/"


script_path="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/recon_struct_script"
rm ${script_path}

# reconstruct struct using subspace
paramfname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_param_gt_subspace2.m"
SUBCMD="cd('${code_path}');sim_invivo_motion('${paramfname}');"
echo $MATLABCMD \"$SUBCMD\" >> ${script_path}
paramfname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_param_gt_subspace3.m"
SUBCMD="cd('${code_path}');sim_invivo_motion('${paramfname}');"
echo $MATLABCMD \"$SUBCMD\" >> ${script_path}
paramfname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_param_gt_subspace4.m"
SUBCMD="cd('${code_path}');sim_invivo_motion('${paramfname}');"
echo $MATLABCMD \"$SUBCMD\" >> ${script_path}
paramfname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_param_gt_subspace5.m"
SUBCMD="cd('${code_path}');sim_invivo_motion('${paramfname}');"
echo $MATLABCMD \"$SUBCMD\" >> ${script_path}

# reconstruct struct using llr
paramfname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_param_gt_llr4.m"
SUBCMD="cd('${code_path}');sim_invivo_motion('${paramfname}');"
echo $MATLABCMD \"$SUBCMD\" >> ${script_path}
# paramfname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_param_gt_llr3.m"
# SUBCMD="cd('${code_path}');sim_invivo_motion('${paramfname}');"
# echo $MATLABCMD \"$SUBCMD\" >> ${script_path}

CMD="$FSLSUBCMD -q short.q -s openmp,12 -t ${script_path}"
ID=$(eval $CMD)

# MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
# for i in {1..98}
# do
#     fsl_sub -q short.q -s openmp,12 -l logs ${MATLABCMD} \"sim_invivo_motion\(\'/vols/Data/okell/qijia/perf_recon_12-10-23/subspace_param_1.m\',\[${i}\]\)\"
#     # fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} \"sim_invivo_motion\(\'/vols/Data/okell/qijia/perf_recon_12-10-23/subspace_param_2.m\',\[$(( 2*i-1 )),$(( 2*i ))\]\)\"
# done
# 1. parallel subspace recon
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"

paramfname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE_motion2/subspace_param_stage3.m"
basname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE_motion2/subspace_motion_stage3/subspace_repeat"
outname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE_motion2/subspace_motion_stage3_combined"
rm recon_subspace_script3
for i in {1..98}
do
    SUBCMD="sim_invivo_motion('${paramfname}',[${i}])"
    echo $MATLABCMD \"$SUBCMD\" >> recon_subspace_script3
done

CMD="$FSLSUBCMD -q short.q -s openmp,4 -t recon_subspace_script3"
ID=$(eval $CMD)


# 2. combine all the results
SUBCMD="fslmerge -t ${outname} "
for i in {1..98}
do
    name="${basname}_${i}.nii.gz"
    SUBCMD="${SUBCMD} ${name}"
done
CMD="$FSLSUBCMD -j ${ID} -q short.q $SUBCMD"
echo $CMD
ID=$(eval $CMD)
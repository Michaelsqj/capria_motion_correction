# MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
# for i in {1..98}
# do
#     fsl_sub -q short.q -s openmp,12 -l logs ${MATLABCMD} \"sim_invivo_motion\(\'/vols/Data/okell/qijia/perf_recon_12-10-23/subspace_param_1.m\',\[${i}\]\)\"
#     # fsl_sub -q long.q -s openmp,12 -l logs ${MATLABCMD} \"sim_invivo_motion\(\'/vols/Data/okell/qijia/perf_recon_12-10-23/subspace_param_2.m\',\[$(( 2*i-1 )),$(( 2*i ))\]\)\"
# done
# 1. parallel subspace recon
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
for j in {1..3}
do
    subfolder="scan_${j}"
    paramfname="/vols/Data/okell/qijia/perf_recon_23-11-23/${subfolder}/subspace_param_stage2.m"
    basname="/vols/Data/okell/qijia/perf_recon_23-11-23/${subfolder}/subspace_motion_stage2/subspace_repeat"
    outname="/vols/Data/okell/qijia/perf_recon_23-11-23/${subfolder}/subspace_motion_stage2_combined"
    rm recon_subspace_script_n${j}
    for i in {1..98}
    do
        SUBCMD="sim_invivo_motion('${paramfname}',[${i}])"
        echo $MATLABCMD \"$SUBCMD\" >> recon_subspace_script_n${j}
    done

    CMD="$FSLSUBCMD -q short.q -s openmp,4 -t recon_subspace_script_n${j}"
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
done
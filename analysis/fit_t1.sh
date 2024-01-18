FSLSUBCMD="$FSLDIR/bin/fsl_sub -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nodisplay -r"

fname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_gt_W_3_1e-4"
maskname="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_gt_L_3_1e-7_0_brain_mask.nii.gz"
# fname=${1}
tmppath="${fname}_tmp"
outpath="$fname"
mkdir -p $outpath
mkdir -p $tmppath
rm fit_t1_script1
# for i in {1..1000}
# do
#     SUBCMD="fit_t1_parallel('${fname}','${maskname}','${tmppath}',${i},1,2)"
#     FILE="${tmppath}/T1_${i}.nii.gz"
#     # if file exists, skip
#     if [ -f "$FILE" ]; then
#         continue
#     else
#         echo $MATLABCMD \"$SUBCMD\" >> fit_t1_script1
#     fi
# done

# CMD="$FSLSUBCMD -q short.q -s openmp,3 -t fit_t1_script1"
# ID=$(eval $CMD)

# SUBCMD="combine_t1\(\'${tmppath}\',\'${outpath}\'\)"
# CMD="$FSLSUBCMD -q short.q  -j $ID $MATLABCMD \"$SUBCMD\""
# eval $CMD
# 2. combine all the results
for typename in "M0" "InvAlpha" "T1" "B1rel"
do
    outname="${outpath}/${typename}"
    SUBCMD="fslmaths ${tmppath}/${typename}_1.nii.gz"
    for i in {2..1000}
    do
        basname="${tmppath}/${typename}"
        name="${basname}_${i}.nii.gz"
        SUBCMD="${SUBCMD} -add ${name}"
    done
    SUBCMD="${SUBCMD} ${outname}"
    CMD="$FSLSUBCMD -s openmp,12 -q short.q $SUBCMD"
    echo $CMD
    ID=$(eval $CMD)
done
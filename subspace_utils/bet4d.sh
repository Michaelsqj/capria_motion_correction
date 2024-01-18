#bin bash
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
fname="/vols/Data/okell/qijia/perf_recon_12-10-23/subspace_3_combined"
tmpdir="/vols/Data/okell/qijia/perf_recon_12-10-23/subspace_3_combined_split/"
tmpdir2="/vols/Data/okell/qijia/perf_recon_12-10-23/subspace_3_combined_split_brain/"
outname="/vols/Data/okell/qijia/perf_recon_12-10-23/subspace_3_combined_brain"
mkdir ${tmpdir}
mkdir ${tmpdir2}

# # 1. split the 4d nifti into 98 3d nifti
# SUBCMD="fslsplit ${fname} ${tmpdir} -t"
# CMD="$FSLSUBCMD -q veryshort.q ${SUBCMD}"
# ID=$(eval $CMD)


# # 2. bet the 3d nifti
# rm bet4d_script
# flist=($(ls -1 ${tmpdir}/*.nii.gz))
# for i in {0..97}
# do
#     SUBCMD="bet ${flist[i]} ${tmpdir2}/$( printf "vol_%04d" ${i} ) -f 0.8"
#     echo $SUBCMD >> bet4d_script
# done
# CMD="$FSLSUBCMD -q veryshort.q -t bet4d_script"
# ID=$(eval $CMD)

# # 3. combine the 3d nifti
# flist=($(ls -1 ${tmpdir2}/*.nii.gz))
# SUBCMD="fslmerge -t ${outname}"
# for i in {0..97}
# do
#     SUBCMD="${SUBCMD} ${flist[i]}"
# done
# CMD="$FSLSUBCMD -q veryshort.q ${SUBCMD}"
# echo $CMD
# ID=$(eval $CMD)
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
inpath="/home/fs0/qijia/scratch/moco_exp/expout/subspace_6-11-23/subspace_motion_1_combined_flip"
outpath="${inpath}_brain"
maskpath="${inpath}_brain_mask"
basename="subspace_repeat"
mkdir -p $outpath
mkdir -p $maskpath
rm synthstrip_script
for i in {1..98}
do
    name="$( printf "vol%04d" $(( i-1 )) )"
    SUBCMD="synthstrip-singularity -i ${inpath}/$name.nii.gz -o ${outpath}/$name.nii.gz -m ${maskpath}/$name.nii.gz"
    echo $SUBCMD >> synthstrip_script
done
CMD="$FSLSUBCMD -q short.q -s openmp,4 -t synthstrip_script"
ID=$(eval $CMD)


SUBCMD="fslmerge -t ${outpath}_combined_synthstrip.nii.gz "
for i in {1..98}
do
    name="$( printf "vol%04d.nii.gz" $(( i-1 )) )"
    SUBCMD="${SUBCMD} ${outpath}/$name"
done
CMD="$FSLSUBCMD -q short.q -s openmp,4 -j $ID $SUBCMD"
echo $CMD
ID=$(eval $CMD)
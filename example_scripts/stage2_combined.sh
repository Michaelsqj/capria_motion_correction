FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
code_path="/home/fs0/qijia/code/moco/"
PYTHONCMD="${HOME}/scratch/conda/envs/pytorch/bin/python"

rootdir=${1}
SUBCMD="echo 'start masking'"
CMD="$FSLSUBCMD -q short.q ${ID} $SUBCMD"
ID=$(eval $CMD)

# 1. mask out the head
inpath="${rootdir}/subspace_motion_stage2"
outpath="${inpath}_masked"
maskname="${rootdir}/mpr_sens_mask.nii.gz"
rm ${rootdir}/mask_script
mkdir -p $outpath
for i in {1..98}
do
    if [ -f "${outpath}/subspace_repeat_${i}.nii.gz" ]; then
        continue
    fi
    SUBCMD="fslmaths ${inpath}/subspace_repeat_${i}.nii.gz -mul ${maskname} ${outpath}/subspace_repeat_${i}.nii.gz"
    echo $SUBCMD >> ${rootdir}/mask_script
done
if [ -f "${rootdir}/mask_script" ]; then
    CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/mask_script"
    ID=$(eval $CMD)
fi

# 2. extract the brain mask


inpath="${rootdir}/subspace_motion_stage2"
flippath="${inpath}_flip"
brain_flip_mask_path="${inpath}_flip_brain_mask"
brain_mask_path="${inpath}_brain_mask"
mkdir -p $flippath
mkdir -p $brain_mask_path
mkdir -p $brain_flip_mask_path
# 2.1. use flip_img to flip all subspace images
rm ${rootdir}/flip_script1
for i in {1..98}
do
    name="subspace_repeat_${i}"
    if [ -f "${flippath}/${name}.nii.gz" ]; then
        continue
    fi
    # SUBCMD="cd('/home/fs0/qijia/code/moco/subspace_utils');flip_img('${inpath}/${name}','${flippath}/${name}');"
    # echo $MATLABCMD \"$SUBCMD\" >> ${rootdir}/flip_script1
    SUBCMD="$PYTHONCMD ${code_path}/subspace_utils/flip_img.py --infile=${inpath}/${name}.nii.gz --outfile=${flippath}/${name}.nii.gz"
    echo $SUBCMD >> ${rootdir}/flip_script1
done
 
if [ -f "${rootdir}/flip_script1" ]; then
    CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/flip_script1"
    ID=$(eval $CMD)
fi

# 2.2. use synthstrip to extract the brain mask
rm ${rootdir}/synthstrip_script
for i in {1..98}
do
    name="subspace_repeat_${i}"
    # if brain mask exist then skip
    if [ -f "${brain_flip_mask_path}/${name}.nii.gz" ]; then
        continue
    fi
    SUBCMD="synthstrip-singularity -i ${flippath}/$name.nii.gz -m ${brain_flip_mask_path}/$name.nii.gz"
    echo $SUBCMD >> ${rootdir}/synthstrip_script
done

if [ -f "${rootdir}/synthstrip_script" ]; then
    CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/synthstrip_script"
    ID=$(eval $CMD)
fi


# 2.3. use flip_img to flip the brain mask back to original orientation
rm ${rootdir}/flip_script2
for i in {1..98}
do
    name="subspace_repeat_${i}"
    if [ -f "${brain_mask_path}/${name}.nii.gz" ]; then
        continue
    fi
    # SUBCMD="cd('/home/fs0/qijia/code/moco/subspace_utils');flip_img('${brain_flip_mask_path}/${name}','${brain_mask_path}/${name}');"
    # echo $MATLABCMD \"$SUBCMD\" >> ${rootdir}/flip_script2
    SUBCMD="$PYTHONCMD ${code_path}/subspace_utils/flip_img.py --infile=${brain_flip_mask_path}/${name}.nii.gz --outfile=${brain_mask_path}/${name}.nii.gz"
    echo $SUBCMD >> ${rootdir}/flip_script2
done

if [ -f "${rootdir}/flip_script2" ]; then
    CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/flip_script2"
    ID=$(eval $CMD)
fi

# 3. flirt registration with brain mask as weight
inpath="${rootdir}/subspace_motion_stage2_masked"
outpath="${inpath}_flirt_combined"
maskpath="${rootdir}/subspace_motion_stage2_brain_mask"
outmat="${rootdir}/subspace_motion_stage2_combined_masked_flirt_combined.mat"
tmpmat="${rootdir}/subspace_motion_stage2_combined_masked_flirt_tmp_combined"
stage1mat="${rootdir}/subspace_motion_stage1_combined_masked_flirt_combined.mat"

mkdir -p $outmat
mkdir -p $outpath
mkdir -p $tmpmat

rm ${rootdir}/flirt_script
# 3.1. register 
for i in {1..98}
do
    refname="subspace_repeat_1"
    movname="subspace_repeat_${i}"
    n=$(( i-1 ))
    outname=$(printf "MAT_%04d" $n)
    SUBCMD="flirt -in ${inpath}/${movname} -ref ${inpath}/${refname} -out ${outpath}/${movname} -omat ${tmpmat}/${outname}\
    -dof 6 -interp spline -nosearch\
    -inweight ${maskpath}/${movname}.nii.gz -refweight ${maskpath}/${refname}.nii.gz"
    echo $SUBCMD >> ${rootdir}/flirt_script
done
CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/flirt_script"
ID=$(eval $CMD)

# 4.2. combine with stage1
rm ${rootdir}/combine_script2
for i in {0..97}
do
    #outname="MAT_0000"
    outname=$(printf "MAT_%04d" $i)
    SUBCMD="convert_xfm -omat ${outmat}/${outname} -concat  ${tmpmat}/${outname} ${stage1mat}/${outname}"
    echo $SUBCMD >> ${rootdir}/combine_script2
done
CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/combine_script2"
ID=$(eval $CMD)
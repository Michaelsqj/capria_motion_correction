#/bin/bash

FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
code_path="/home/fs0/qijia/code/moco/"
PYTHONCMD="${HOME}/scratch/conda/envs/pytorch/bin/python"

rootdir=${1}
inpath="${rootdir}/subspace_motion_stage1"
outpath="${inpath}_masked"
maskname="${rootdir}/mpr_sens_mask.nii.gz"

rm ${rootdir}/mask_script
mkdir -p $outpath

SUBCMD="echo 'start masking'"
CMD="$FSLSUBCMD -q short.q ${ID} $SUBCMD"
ID=$(eval $CMD)

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


inpath="${rootdir}/subspace_motion_stage1_masked"
outpath="${inpath}_flirt_combined"
# matpath="${inpath}_mat"
# matpath_cntl="${inpath}_matcntl"
outmat="${rootdir}/subspace_motion_stage1_combined_masked_flirt_combined.mat"

mkdir -p $outpath
mkdir -p $outmat
# mkdir -p $matpath
# mkdir -p $matpath_cntl
rm ${rootdir}/flirt_script1
# 1. register each tag to first tag
for i in {1..98}
do
    refname="subspace_repeat_1"
    movname="subspace_repeat_${i}"
    n=$(( i-1 ))
    outname=$(printf "MAT_%04d" $n)
    SUBCMD="flirt -in ${inpath}/${movname} -ref ${inpath}/${refname} -out ${outpath}/${movname} -omat ${outmat}/${outname} -dof 6 -cost leastsq -interp spline -nosearch"
    echo $SUBCMD >> ${rootdir}/flirt_script1
done
CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/flirt_script1"
ID=$(eval $CMD)


#------------------------ 2. rotate sens  ------------------------#
orig_sens_file="${rootdir}/sens0.mat"
ref_file="${rootdir}/anat0.nii.gz"
split_sens_real="${rootdir}/sens0_real.nii.gz"
split_sens_imag="${rootdir}/sens0_imag.nii.gz"
rotated_sens_path="${rootdir}/subspace_motion_stage1_rotated_sens0/"

xfm_path="${rootdir}/subspace_motion_stage1_combined_masked_flirt_combined.mat"

mkdir -p $rotated_sens_path

# 1. load sens mat, save as _real, _imag nifti
SUBCMD="$PYTHONCMD ${code_path}/sens_estimate/mat2nii.py --mat_file=${orig_sens_file} --ref_file=${ref_file}"
CMD="$FSLSUBCMD -q short.q -j ${ID} $SUBCMD"
ID=$(eval $CMD)

# 2. using flirt to rotate sens real and imag nifti
rm ${rootdir}/rotate_script
for ii in {1..98}
do
    n=$(( $ii - 1 ))
    name=$(printf "MAT_%04d" $n)
    # 2.1. rotate _real
    SUBCMD="applyxfm4D ${split_sens_real} ${split_sens_real} ${rotated_sens_path}/sens_real_${ii} ${xfm_path}/${name} -singlematrix"
    echo $SUBCMD >> ${rootdir}/rotate_script

    # 2.2. rotate _imag
    SUBCMD="applyxfm4D ${split_sens_imag} ${split_sens_imag} ${rotated_sens_path}/sens_imag_${ii} ${xfm_path}/${name} -singlematrix"
    echo $SUBCMD >> ${rootdir}/rotate_script    
done
CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/rotate_script"
ID=$(eval $CMD)


# 3. combine rotated _real and _imag nifti to sens mat
rm ${rootdir}/combine_script
for ii in {1..98}
do
    SUBCMD="$PYTHONCMD ${code_path}/sens_estimate/nii2mat.py --nii_real_file=${rotated_sens_path}/sens_real_${ii}.nii.gz"
    echo $SUBCMD >> ${rootdir}/combine_script
done
CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/combine_script"
ID=$(eval $CMD)

# 4. rm rotated sens nifti
SUBCMD="rm ${rotated_sens_path}/*.nii.gz"
CMD="$FSLSUBCMD -q short.q -j ${ID} $SUBCMD"
ID=$(eval $CMD)
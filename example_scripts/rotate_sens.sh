FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
code_path="/home/fs0/qijia/code/moco/"
PYTHONCMD="${HOME}/scratch/conda/envs/pytorch/bin/python"

rootdir=${1}

orig_sens_file="${rootdir}/sens0.mat"
ref_file="${rootdir}/anat0.nii.gz"
split_sens_real="${rootdir}/sens0_real.nii.gz"
split_sens_imag="${rootdir}/sens0_imag.nii.gz"
rotated_sens_path="${rootdir}/rotated_sens0/"

xfm_path="${rootdir}/subspace_motion_stage1_combined_masked_flirt_combined.mat"

mkdir -p $rotated_sens_path

# 1. load sens mat, save as _real, _imag nifti
SUBCMD="$PYTHONCMD ${code_path}/sens_estimate/mat2nii.py --mat_file=${orig_sens_file} --ref_file=${ref_file}"
CMD="$FSLSUBCMD -q short.q $SUBCMD"
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
    SUBCMD="$PYTHONCMD ${code_path}/sens_estimate/nii2mat.py --nii_real_file=${rotated_sens_path}/sens_real_${ii}"
    echo $SUBCMD >> ${rootdir}/combine_script
done
CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/combine_script"
ID=$(eval $CMD)
#/bin/bash

FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"

rootdir=${1}
inpath="${rootdir}/subspace_motion_stage1"
outpath="${inpath}_masked"
maskname="${rootdir}/mpr_sens_mask.nii.gz"

rm ${rootdir}/mask_script
mkdir -p $outpath
for i in {1..98}
do
    SUBCMD="fslmaths ${inpath}/subspace_repeat_${i}.nii.gz -mul ${maskname} ${outpath}/subspace_repeat_${i}.nii.gz"
    echo $SUBCMD >> ${rootdir}/mask_script
done
CMD="$FSLSUBCMD -q short.q -t ${rootdir}/mask_script"
ID=$(eval $CMD)


inpath="${rootdir}/subspace_motion_stage1_masked"
outpath="${inpath}_flirt"
matpath="${inpath}_mat"
matpath_cntl="${inpath}_matcntl"

mkdir -p $outpath
mkdir -p $matpath
mkdir -p $matpath_cntl
rm ${rootdir}/flirt_script1
# 1. register each tag to first tag
for i in {1..49}
do
    refname="subspace_repeat_1"
    movname="subspace_repeat_$(( 2*i-1 ))"
    SUBCMD="flirt -in ${inpath}/${movname} -ref ${inpath}/${refname} -out ${outpath}/${movname} -omat ${matpath}/${movname} -dof 6 -cost leastsq -interp spline -nosearch"
    echo $SUBCMD >> ${rootdir}/flirt_script1
done
CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/flirt_script1"
ID=$(eval $CMD)

# 2. register each control to nearby tag
rm ${rootdir}/flirt_script2
for i in {1..49}
do
    refname="subspace_repeat_$(( 2*i-1 ))"
    movname="subspace_repeat_$(( 2*i ))"
    SUBCMD="flirt -in ${inpath}/${movname} -ref ${inpath}/${refname} -omat ${matpath_cntl}/${movname} -dof 6 -cost leastsq -interp spline -nosearch"
    echo $SUBCMD >> ${rootdir}/flirt_script2
done
CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/flirt_script2"
ID=$(eval $CMD)

# 3. convert_xfm
inpath="${rootdir}/subspace_motion_stage1_masked"
outmat="${rootdir}/subspace_motion_stage1_combined_masked_flirt.mat"
tag_mat="${inpath}_mat"
cntl_mat="${inpath}_matcntl"

mkdir -p $outmat
rm ${rootdir}/combine_script
for i in {1..49}
do
    #outname="MAT_0000"
    n=$(( 2*i-2 ))
    outname=$(printf "MAT_%04d" $n)
    SUBCMD="cp ${tag_mat}/subspace_repeat_$(( 2*i-1 )) ${outmat}/${outname}"
    echo $SUBCMD >> ${rootdir}/combine_script
    n=$(( 2*i-1 ))
    outname=$(printf "MAT_%04d" $n)
    SUBCMD="convert_xfm -omat ${outmat}/${outname} -concat ${tag_mat}/subspace_repeat_$(( 2*i-1 )) ${cntl_mat}/subspace_repeat_$(( 2*i ))"
    echo $SUBCMD >> ${rootdir}/combine_script
done
CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${rootdir}/combine_script"
ID=$(eval $CMD)

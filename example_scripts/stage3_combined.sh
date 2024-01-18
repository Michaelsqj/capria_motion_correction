FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"

perf_dir=${1}
angi_dir=${2}
code_path="/home/fs0/qijia/code/moco"
# 1. register anat to static anat
inpath="${perf_dir}/subspace_motion_stage2_combined_masked_flirt_combined.mat"
perf_outpath="${perf_dir}/subspace_motion_stage3_combined_masked_flirt.mat"
angi_outpath="${angi_dir}/subspace_motion_stage3_combined_masked_flirt.mat"
xfm1="${perf_dir}/anat2_regxfm"
xfm2="${angi_dir}/anat2_regxfm"

mkdir -p ${perf_outpath}
mkdir -p ${angi_outpath}

# 2. concatenate transforms
# convert_xfm -omat <outmat_AtoC> -concat <mat_BtoC> <mat_AtoB>
rm ${perf_dir}/combine_script
for i in {0..97}
do
    outname=$(printf "MAT_%04d" $i)
    SUBCMD="convert_xfm -omat ${perf_outpath}/${outname} -concat ${xfm1} ${inpath}/${outname}"
    echo $SUBCMD >> ${perf_dir}/combine_script
done
CMD="$FSLSUBCMD -q short.q -t ${perf_dir}/combine_script"
ID=$(eval $CMD)


rm ${angi_dir}/combine_script
for i in {0..97}
do
    outname=$(printf "MAT_%04d" $i)
    SUBCMD="convert_xfm -omat ${angi_outpath}/${outname} -concat ${xfm2} ${inpath}/${outname}"
    echo $SUBCMD >> ${angi_dir}/combine_script
done
CMD="$FSLSUBCMD -q short.q -t ${angi_dir}/combine_script"
ID=$(eval $CMD)

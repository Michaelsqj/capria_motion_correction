FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
inpath="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/subspace_motion_stage2/"
outpath="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/subspace_motion_stage2_flirt/"
matpath="/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/subspace_motion_stage2_mat/"
for i in {1..49}
do
    refname="subspace_repeat_$(( 2*i-1 ))"
    movname="subspace_repeat_$(( 2*i ))"
    SUBCMD="flirt -in ${inpath}/${movname} -ref ${inpath}/${refname} -out ${outpath}/${movname} -omat ${matpath}/${movname} -dof 6"
done
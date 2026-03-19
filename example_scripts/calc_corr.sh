# Define the parameters for the reconstruction pipeline
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
code_path="/home/fs0/qijia/code/moco/"
# date: "15-11-23" "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"
# date="28-11-23"
for date in "15-11-23" "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"
do
    echo "date: ${date}"
    
    if [ ${date} == "15-11-23" ]; then
        mov_inds=(1 2 3)  # moving scan index
        static_ind=4    # static scan index
        # inds=(4)
    else
        mov_inds=(1 2)  # moving scan index
        static_ind=3    # static scan index
        # inds=(2)
    fi
    # mov_inds=(1 2)  # moving scan index
    # static_ind=3    # static scan index
    inds=(${mov_inds[@]} ${static_ind[@]})
    # inds=${mov_inds[@]}

    recon_path="/vols/Data/okell/qijia/recon_${date}"
    perf_recon_path="/vols/Data/okell/qijia/perf_recon_${date}"

    step_ind=3
    # calculate correlation in perfusion and structural
    if [[ ${step_ind} -eq 2 ]]; then
        script_path="${perf_recon_path}/scan_${ind}/corr_script"
        # perfusion image before correction
        img1_fpath="${perf_recon_path}/scan_${ind}/perfusion_gt.nii.gz"
        # perfusion image reference
        img2_fpath="${perf_recon_path}/scan_${static_ind}/perfusion_stage3.nii.gz"
        # mask for perfusion image
        mask_name="anat2_brain_mask.nii.gz"
        mask_fpath="${perf_recon_path}/scan_${static_ind}/${mask_name}"
        write_fpath="${perf_recon_path}/scan_${ind}/corr.txt"
        # calculate correlation
        SUBCMD="cd('${code_path}');include_path();correlation('${img1_fpath}', '${img2_fpath}', '${mask_fpath}', '${write_fpath}')"
        echo $MATLABCMD \"$SUBCMD\" > ${script_path}
        CMD="$FSLSUBCMD -q short.q -t ${script_path}"
        ID=$(eval $CMD)

        # perfusion image after correction
        img2_fpath="${perf_recon_path}/scan_${ind}/perfusion_stage3.nii.gz"
    fi

done
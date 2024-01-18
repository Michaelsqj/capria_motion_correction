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

    step_ind=2
    script_path="${recon_path}/mask_extraction"
    rm ${script_path}
    if [[ ${step_ind} -eq 1 ]]; then
        # 1. brain extraction for static_ind
        subfolder="scan_${static_ind}"

        # input="${recon_path}/${subfolder}/anat2"
        # output="${recon_path}/${subfolder}/anat2_brain"
        # SUBCMD="bet ${input} ${output} -m"
        # echo $SUBCMD >> ${script_path}

        # input="${perf_recon_path}/${subfolder}/anat2"
        # output="${perf_recon_path}/${subfolder}/anat2_brain"
        # SUBCMD="bet ${input} ${output} -m"
        # echo $SUBCMD >> ${script_path}

        # CMD="$FSLSUBCMD -q short.q -t ${script_path}"
        # ID=$(eval $CMD)

        # 2. dilated vessel mask extraction
        DataPath="${recon_path}/scan_${static_ind}/angio_stage3"
        if [ ! -f "${DataPath}" ]; then
            DataPath="${recon_path}/scan_${static_ind}/angio_gt"
        fi
        AngioVesMaskName="${DataPath}_vessel_mask"
        AngioDilVesMaskName="${DataPath}_dil_vessel_mask"
        BMaskName="${recon_path}/scan_${static_ind}/anat2_brain_mask"
        SUBCMD="cd('${code_path}');include_path();CreateDilatedVesselMask('${DataPath}','${AngioVesMaskName}','${AngioDilVesMaskName}','${BMaskName}')"
        echo $MATLABCMD \"$SUBCMD\" > ${script_path}
        CMD="$FSLSUBCMD -q short.q -t ${script_path}"
        ID=$(eval $CMD)
    fi

    if [[ ${step_ind} -eq 2 ]]; then
        # 1. calculate correlation of perfusion between mov_ind and static_ind
        for ind in ${mov_inds[@]}
        do
            subfolder="scan_${ind}"
            script_path="${perf_recon_path}/${subfolder}/corr_calculation_script"
            rm ${script_path}
            # 1. calculate correlation of perfusion
            
            img1_fpath="${perf_recon_path}/${subfolder}/perfusion_gt.nii.gz"
            img2_fpath="${perf_recon_path}/scan_${static_ind}/perfusion_stage3.nii.gz"
            mask_fpath="${perf_recon_path}/scan_${static_ind}/anat2_brain_mask.nii.gz"
            write_fpath="${perf_recon_path}/scan_${ind}/perfusion_gt_corr"
            SUBCMD="correlation($img1_fpath, $img2_fpath, $mask_fpath, $write_fpath)"
            echo $MATLABCMD \"$SUBCMD\" >> ${script_path}

            img1_fpath="${perf_recon_path}/${subfolder}/perfusion_stage3.nii.gz"
            write_fpath="${perf_recon_path}/scan_${ind}/perfusion_stage3_corr"
            SUBCMD="correlation($img1_fpath, $img2_fpath, $mask_fpath, $write_fpath)"
            echo $MATLABCMD \"$SUBCMD\" >> ${script_path}
            CMD="$FSLSUBCMD -q short.q -t ${script_path}"
            ID=$(eval $CMD)

            # 2. calculate correlation of angiogram
            script_path="${recon_path}/${subfolder}/corr_calculation_script"
            rm ${script_path}
            img1_fpath="${recon_path}/${subfolder}/angio_gt.nii.gz"
            DataPath="${recon_path}/scan_${static_ind}/angio_stage3"
            if [ ! -f "${DataPath}" ]; then
                DataPath="${recon_path}/scan_${static_ind}/angio_gt"
            fi
            img2_fpath="${DataPath}.nii.gz"
            AngioVesMaskName="${DataPath}_vessel_mask"
            AngioDilVesMaskName="${DataPath}_dil_vessel_mask"
            write_fpath="${recon_path}/scan_${ind}/angio_gt_corr"
            SUBCMD="correlation($img1_fpath, $img2_fpath, $AngioDilVesMaskName, $write_fpath)"
            echo $MATLABCMD \"$SUBCMD\" >> ${script_path}

            img1_fpath="${recon_path}/${subfolder}/angio_stage3.nii.gz"
            write_fpath="${recon_path}/scan_${ind}/angio_stage3_corr"
            SUBCMD="correlation($img1_fpath, $img2_fpath, $AngioDilVesMaskName, $write_fpath)"
            echo $MATLABCMD \"$SUBCMD\" >> ${script_path}
            CMD="$FSLSUBCMD -q short.q -t ${script_path}"
            ID=$(eval $CMD)
        done
    fi
done
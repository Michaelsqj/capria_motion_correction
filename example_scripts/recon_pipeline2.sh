# Define the parameters for the reconstruction pipeline
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
code_path="/home/fs0/qijia/code/moco/"
# date: "15-11-23" "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"
# date="28-11-23"
for date in "15-11-23"
do
    echo "date: ${date}"
    
    if [ ${date} == "15-11-23" ]; then
        mov_inds=(1 2 3)  # moving scan index
        static_ind=4    # static scan index
        inds=(4)
    else
        mov_inds=(1 2)  # moving scan index
        static_ind=3    # static scan index
        # inds=(2)
    fi
    # mov_inds=(1 2)  # moving scan index
    # static_ind=3    # static scan index
    inds=(${mov_inds[@]} ${static_ind[@]})
    # inds=${mov_inds[@]}
    


    raw_data_path="/vols/Data/okell/qijia/raw_data_${date}"
    recon_path="/vols/Data/okell/qijia/recon_${date}"
    perf_recon_path="/vols/Data/okell/qijia/perf_recon_${date}"
    mkdir -p ${recon_path}
    mkdir -p ${perf_recon_path}

    for ind in ${inds[@]}
    do
        mkdir -p ${recon_path}/scan_${ind}
        mkdir -p ${perf_recon_path}/scan_${ind}
    done

    step_ind=12
    #-----------------------------------------------------
    # Stage 0: reconstruct anat (perf/angi) for all scans, and reconstruct mprage t
    #           estimate coils sensitivity for all scans and mprage t1
    #-----------------------------------------------------
    # 1. reconstruct anat (perf/angi) for three scans, reconstruct mprage t1 
    if [[ ${step_ind} -eq 1 ]]; then
        for ind in ${inds[@]}
        do
            rm ${recon_path}/scan_${ind}/recon_anat_script1
            paramfname="${code_path}/example_scripts/anat_param_stage0.m"
            SUBCMD="cd('${code_path}'); p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p);"
            echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/scan_${ind}/recon_anat_script1
            CMD="$FSLSUBCMD -q short.q -s openmp,8 -t ${recon_path}/scan_${ind}/recon_anat_script1"
            ID=$(eval $CMD)

            rm ${perf_recon_path}/scan_${ind}/recon_anat_script1
            paramfname="${code_path}/example_scripts/anat_angi_param_stage0.m"
            SUBCMD="cd('${code_path}'); p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p);"
            echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/scan_${ind}/recon_anat_script1
            CMD="$FSLSUBCMD -q short.q -s openmp,8 -t ${perf_recon_path}/scan_${ind}/recon_anat_script1"
            ID=$(eval $CMD)
        done

        SUBCMD="cd('${code_path}'); include_path(); recon_t1('${date}')"
        echo $MATLABCMD \"$SUBCMD\" > ${perf_recon_path}/scan_${ind}/recon_anat_script1_1
        CMD="$FSLSUBCMD -q short.q -s openmp,8 -t ${perf_recon_path}/scan_${ind}/recon_anat_script1_1"
        ID=$(eval $CMD)
    fi


    # 2. estimate coil sensitivity for three scans, estimate coil sensitivity for mprage t1
    if [[ ${step_ind} -eq 2 ]]; then
        cwd=$(pwd)
        cd /home/fs0/qijia/code/SimTraj/MChiewCAPRIARecon/
        # for i in ${inds[@]}
        # do
        #     fpath="${perf_recon_path}/scan_${i}"
        #     flist=($(ls -1 ${fpath}/*anat0.mat))
        #     echo ${flist}
        #     ./qsens -n 1000 -t 0.001 -q short.q ${flist[0]}
        # done
        # for i in ${inds[@]}
        # do
        #     fpath="${recon_path}/scan_${i}"
        #     flist=($(ls -1 ${fpath}/*anat0.mat))
        #     echo ${flist}
        #     ./qsens -n 1000 -t 0.001 -q short.q ${flist[0]}
        # done
        # 2.2 sens estimate for t1
        fpath="/vols/Data/okell/qijia/raw_data_${date}"
        flist=($(ls -1 ${fpath}/*PSN_anat.mat))
        echo ${flist}
        ./qsens -n 1000 -t 0.001 -q short.q ${flist[0]}
        cd ${cwd}
    fi


    # 3. register scan 1/2 anat (perf/angi) to scan 3 anat, register mprage t1 to anat (perf/angi)
    #    this xfm will only be used for reconstructing before correction image
    if [[ ${step_ind} -eq 3 ]]; then
        rm ${code_path}/parallel_scritps/register_anat_script0
        # !!!!manual
        # adjust thresh mprage t1 and angio
        fpath="/vols/Data/okell/qijia/raw_data_${date}"
        flist=($(ls -1 ${fpath}/*PSN_sens.mat))
        SUBCMD="cd('${code_path}');include_path();adjust_thresh('${flist[0]}',0.037,[])"
        echo $MATLABCMD \"$SUBCMD\" >> ${code_path}/parallel_scritps/register_anat_script0
        CMD="$FSLSUBCMD -q short.q -t ${code_path}/parallel_scritps/register_anat_script0"
        ID=$(eval $CMD)

        # extract first sens frame using fslroi
        flist=($(ls -1 ${fpath}/*PSN_sens.nii.gz))
        sensname="${flist[0]}"
        sens0name=${sensname/sens/sens_0}
        SUBCMD="fslroi ${sensname} ${sens0name} 0 1"
        CMD="$FSLSUBCMD -q short.q -j ${ID} $SUBCMD"
        ID=$(eval $CMD)

        # register mprage t1 to anat (perf/angi)
        flist=($(ls -1 ${fpath}/*PSN_anat.nii.gz))
        anatname="${flist[0]}"
        SUBCMD="flirt -in ${anatname} -ref ${perf_recon_path}/scan_${static_ind}/anat0 -out ${perf_recon_path}/scan_${static_ind}/mpr_anat -omat ${perf_recon_path}/scan_${static_ind}/mpr2anat_regxfm -dof 6"
        CMD="$FSLSUBCMD -q short.q -j ${ID} $SUBCMD"
        ID=$(eval $CMD)
        
        # apply xfm to sens0
        SUBCMD="flirt -in ${sens0name} -ref ${perf_recon_path}/scan_${static_ind}/anat0 -out ${perf_recon_path}/scan_${static_ind}/mpr_sens -applyxfm -init ${perf_recon_path}/scan_${static_ind}/mpr2anat_regxfm"
        CMD="$FSLSUBCMD -q short.q -j ${ID} $SUBCMD"
        ID=$(eval $CMD)

        # binarize and process mpr_sens
        SUBCMD="cd('${code_path}'); include_path(); process_sens_mask('${perf_recon_path}/scan_${static_ind}/mpr_sens')"
        echo $MATLABCMD \"$SUBCMD\" > ${code_path}/parallel_scritps/register_anat_script0_1
        CMD="$FSLSUBCMD -q short.q -j ${ID} -t ${code_path}/parallel_scritps/register_anat_script0_1"
        ID=$(eval $CMD)

        for ind in ${mov_inds[@]}
        do
            SUBCMD="cp ${perf_recon_path}/scan_${static_ind}/mpr_sens_mask.nii.gz ${perf_recon_path}/scan_${ind}/mpr_sens_mask.nii.gz"
            CMD="$FSLSUBCMD -q short.q -j ${ID} $SUBCMD"
            ID=$(eval $CMD)
        done
    fi


    #-----------------------------------------------------  
    # Stage 1: reconstruct perfusion for scan_1 and scan_2
    #-----------------------------------------------------

    # 4. subspace reconstruct stage1 for scan_1 and scan_2
    if [[ ${step_ind} -eq 4 ]]; then
        for ind in ${inds[@]}
        do
            subfolder="scan_${ind}"
            paramfname="${code_path}/example_scripts/subspace_param_stage1.m"
            basname="${perf_recon_path}/${subfolder}/subspace_motion_stage1/subspace_repeat"
            outname="${perf_recon_path}/${subfolder}/subspace_motion_stage1_combined"
            # 4.1. parallel subspace recon
            rm ${perf_recon_path}/${subfolder}/recon_subspace_script_n1
            for i in {1..98}
            do
                SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};p.shot_ind=${i};sim_invivo_motion('${paramfname}',p)"
                echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/${subfolder}/recon_subspace_script_n1
            done

            CMD="$FSLSUBCMD -q short.q -s openmp,4 -t ${perf_recon_path}/${subfolder}/recon_subspace_script_n1"
            ID=$(eval $CMD)

            # 4.2. combine all the results
            SUBCMD="fslmerge -t ${outname} "
            for i in {1..98}
            do
                name="${basname}_${i}.nii.gz"
                SUBCMD="${SUBCMD} ${name}"
            done
            CMD="$FSLSUBCMD -j ${ID} -q short.q $SUBCMD"
            echo $CMD
            ID=$(eval $CMD)
        done
    fi


    # 5. run stage1.sh for scan_1 and scan_2
    if [[ ${step_ind} -eq 5 ]]; then
        for ind in ${inds[@]}
        do
            bash ${code_path}/example_scripts/stage1_combined.sh ${perf_recon_path}/scan_${ind}
            # bash ${code_path}/example_scripts/stage1_combined_brain.sh ${perf_recon_path}/scan_${ind}
        done
    fi

    #-----------------------------------------------------
    # Stage 2: stage2 reconstruction of subspace repeat
    #-----------------------------------------------------

    # 6. subspace reconstruct stage2 for scan_1 and scan_2
    if [[ ${step_ind} -eq 6 ]]; then
        for ind in ${inds[@]}
        do
            subfolder="scan_${ind}"
            paramfname="${code_path}/example_scripts/subspace_param_stage2.m"
            basname="${perf_recon_path}/${subfolder}/subspace_motion_stage2/subspace_repeat"
            outname="${perf_recon_path}/${subfolder}/subspace_motion_stage2_combined"
            # 6.1. parallel subspace recon
            rm ${perf_recon_path}/${subfolder}/recon_subspace_script_n2
            for i in {1..98}
            do
                if [ -f "${perf_recon_path}/${subfolder}/subspace_motion_stage2/subspace_repeat_${i}.nii.gz" ]; then
                    continue
                fi
                SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};p.shot_ind=${i};sim_invivo_motion('${paramfname}',p)"
                echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/${subfolder}/recon_subspace_script_n2
            done

            CMD="$FSLSUBCMD -q short.q -s openmp,2 -t ${perf_recon_path}/${subfolder}/recon_subspace_script_n2"
            ID=$(eval $CMD)

            # 6.2. combine all the results
            SUBCMD="fslmerge -t ${outname} "
            for i in {1..98}
            do
                name="${basname}_${i}.nii.gz"
                SUBCMD="${SUBCMD} ${name}"
            done
            CMD="$FSLSUBCMD -j ${ID} -q short.q $SUBCMD"
            echo $CMD
            ID=$(eval $CMD)
        done
    fi

    # 7. run stage2.sh for scan_1 and scan_2
    if [[ ${step_ind} -eq 7 ]]; then
        for ind in ${inds[@]}
        do
            bash ${code_path}/example_scripts/stage2_combined.sh ${perf_recon_path}/scan_${ind}
        done
    fi

    # 8. reconstruct anat2 with mcf 
    if [[ ${step_ind} -eq 8 ]]; then
        # rm ${perf_recon_path}/scan_${ind}/recon_anat_script2
        for ind in ${inds[@]}
        do
            paramfname="${code_path}/example_scripts/anat_param_stage2.m"
            mcf_mat="${perf_recon_path}/scan_${ind}/subspace_motion_stage2_combined_masked_flirt.mat"
            SUBCMD="cd('${code_path}');include_path();p.date='${date}';p.ind=${ind};p.mcf_mat='${mcf_mat}';sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" > ${perf_recon_path}/scan_${ind}/recon_anat_script2
            
            paramfname="${code_path}/example_scripts/anat_param_stage1.m"
            mcf_mat="${perf_recon_path}/scan_${ind}/subspace_motion_stage1_combined_masked_flirt.mat"
            SUBCMD="cd('${code_path}');include_path();p.date='${date}';p.ind=${ind};p.mcf_mat='${mcf_mat}';sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/scan_${ind}/recon_anat_script2
            CMD="$FSLSUBCMD -q short.q -s openmp,8 -t ${perf_recon_path}/scan_${ind}/recon_anat_script2"
            ID=$(eval $CMD)
            
            paramfname="${code_path}/example_scripts/anat_angi_param_stage2.m"
            mcf_mat="${perf_recon_path}/scan_${ind}/subspace_motion_stage2_combined_masked_flirt.mat"
            SUBCMD="cd('${code_path}');include_path();p.date='${date}';p.ind=${ind};p.mcf_mat='${mcf_mat}';sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" > ${recon_path}/scan_${ind}/recon_anat_script2
            CMD="$FSLSUBCMD -q short.q -s openmp,8 -t ${recon_path}/scan_${ind}/recon_anat_script2"
            ID=$(eval $CMD)
        done
    fi

    # 9. register
    #       anat0 of scan_1, 2 -> scan_3
    #          perfusion
    #          struct
    #       anat2 of scan_1, 2 -> scan_3
    #          perfusion
    #          struct
    if [[ ${step_ind} -eq 9 ]]; then
        for ind in ${inds[@]}
        do
            # perf recon
            SUBCMD="flirt -in ${perf_recon_path}/scan_${ind}/anat0 -ref ${perf_recon_path}/scan_${static_ind}/anat0 -out ${perf_recon_path}/scan_${ind}/anat0_reg -omat ${perf_recon_path}/scan_${ind}/anat0_regxfm -dof 6"
            CMD="$FSLSUBCMD -q short.q $SUBCMD"
            ID=$(eval $CMD)
            SUBCMD="flirt -in ${perf_recon_path}/scan_${ind}/anat1 -ref ${perf_recon_path}/scan_${static_ind}/anat1 -out ${perf_recon_path}/scan_${ind}/anat1_reg -omat ${perf_recon_path}/scan_${ind}/anat1_regxfm -dof 6"
            CMD="$FSLSUBCMD -q short.q $SUBCMD"
            ID=$(eval $CMD)
            SUBCMD="flirt -in ${perf_recon_path}/scan_${ind}/anat2 -ref ${perf_recon_path}/scan_${static_ind}/anat2 -out ${perf_recon_path}/scan_${ind}/anat2_reg -omat ${perf_recon_path}/scan_${ind}/anat2_regxfm -dof 6"
            CMD="$FSLSUBCMD -q short.q $SUBCMD"
            ID=$(eval $CMD)
            # recon
            SUBCMD="flirt -in ${recon_path}/scan_${ind}/anat0 -ref ${recon_path}/scan_${static_ind}/anat0 -out ${recon_path}/scan_${ind}/anat0_reg -omat ${recon_path}/scan_${ind}/anat0_regxfm -dof 6"
            CMD="$FSLSUBCMD -q short.q $SUBCMD"
            ID=$(eval $CMD)
            SUBCMD="flirt -in ${recon_path}/scan_${ind}/anat2 -ref ${recon_path}/scan_${static_ind}/anat2 -out ${recon_path}/scan_${ind}/anat2_reg -omat ${recon_path}/scan_${ind}/anat2_regxfm -dof 6"
            CMD="$FSLSUBCMD -q short.q $SUBCMD"
            ID=$(eval $CMD)
        done
    fi


    # 10. add additional xfm and to flirt matrix stage 2
    if [[ ${step_ind} -eq 10 ]]; then
        for ind in ${inds[@]}
        do
            bash ${code_path}/example_scripts/stage3_combined.sh ${perf_recon_path}/scan_${ind} ${recon_path}/scan_${ind}
        done
    fi

    # 11. reconstruct anat with mcf for scan_1 and scan_2 check stage3 converted xfm
    if [[ ${step_ind} -eq 11 ]]; then
        # rm ${perf_recon_path}/scan_${ind}/recon_anat_script3
        for ind in ${inds[@]}
        do
            paramfname="${code_path}/example_scripts/anat_param_stage3.m"
            mcf_mat="${perf_recon_path}/scan_${ind}/subspace_motion_stage3_combined_masked_flirt.mat"
            SUBCMD="cd('${code_path}');include_path();p.date='${date}';p.ind=${ind};p.mcf_mat='${mcf_mat}';sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" > ${perf_recon_path}/scan_${ind}/recon_anat_script3
            CMD="$FSLSUBCMD -q short.q -s openmp,8 -t ${perf_recon_path}/scan_${ind}/recon_anat_script3"
            ID=$(eval $CMD)
            
            paramfname="${code_path}/example_scripts/anat_angi_param_stage3.m"
            mcf_mat="${recon_path}/scan_${ind}/subspace_motion_stage3_combined_masked_flirt.mat"
            SUBCMD="cd('${code_path}');include_path();p.date='${date}';p.ind=${ind};p.mcf_mat='${mcf_mat}';sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" > ${recon_path}/scan_${ind}/recon_anat_script3
            CMD="$FSLSUBCMD -q short.q -s openmp,8 -t ${recon_path}/scan_${ind}/recon_anat_script3"
            ID=$(eval $CMD)
        done
    fi

    # 12. reconstruct angio and struct after mcf and additional xfm for scan_1 and scan_2
    #      perfusion, angio, structural for mov scans before and after motion correction
    #      perfusion, angio, structural for static scan without correction as it is
    if [[ ${step_ind} -eq 12 ]]; then

        for ind in ${inds[@]}
        do
            subfolder="scan_${ind}"
            rm ${perf_recon_path}/${subfolder}/recon_perf_script3
            rm ${recon_path}/${subfolder}/recon_angio_script3

            # --------------------------------------
            # perfusion
            # --------------------------------------
            paramfname="${code_path}/example_scripts/perfusion_param_gt.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${perf_recon_path}/scan_${ind}/anat2_regxfm';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            # echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/${subfolder}/recon_perf_script3

            mcf_mat="${perf_recon_path}/scan_${ind}/subspace_motion_stage1_combined_masked_flirt_combined_brain.mat"
            paramfname="${code_path}/example_scripts/perfusion_param_stage1_brain.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            # echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/${subfolder}/recon_perf_script3

            mcf_mat="${perf_recon_path}/scan_${ind}/subspace_motion_stage3_combined_masked_flirt.mat"
            paramfname="${code_path}/example_scripts/perfusion_param_stage3.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            # echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/${subfolder}/recon_perf_script3

            CMD="$FSLSUBCMD -q short.q -s openmp,8 -t ${perf_recon_path}/${subfolder}/recon_perf_script3"
            # ID=$(eval $CMD)

            # --------------------------------------
            # angio and struct
            # --------------------------------------
            paramfname="${code_path}/example_scripts/angio_param_gt.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${recon_path}/scan_${ind}/anat2_regxfm';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            # echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

            mcf_mat="${recon_path}/scan_${ind}/subspace_motion_stage3_combined_masked_flirt.mat"
            # paramfname="${code_path}/example_scripts/angio_param_stage3.m"
            # SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            # echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

            paramfname="${code_path}/example_scripts/angio_param_stage3_1.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

            paramfname="${code_path}/example_scripts/angio_param_stage3_2.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3
            
            paramfname="${code_path}/example_scripts/angio_param_stage3_3.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

            paramfname="${code_path}/example_scripts/struct_param_gt.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${recon_path}/scan_${ind}/anat2_regxfm';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            # echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

            mcf_mat="${recon_path}/scan_${ind}/subspace_motion_stage3_combined_masked_flirt.mat"
            paramfname="${code_path}/example_scripts/struct_param_stage3.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            # echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

            CMD="$FSLSUBCMD -q long.q -s openmp,12 -t ${recon_path}/${subfolder}/recon_angio_script3"
            ID=$(eval $CMD)

        done
    fi

    # if [[ ${step_ind} -eq 13 ]]; then
    #     for ind in ${inds[@]}
    #     do
    #         subfolder="scan_${ind}"
    #         # remove subspace_motion_stage2*, subspace_motion_stage3* in perf_recon_path and recon_path
    #         # rm -r ${perf_recon_path}/${subfolder}/struct_stage3*
    #         # rm -r ${perf_recon_path}/${subfolder}/struct_gt*
    #         rm -r ${recon_path}/${subfolder}/struct_stage3*
    #         rm -r ${recon_path}/${subfolder}/struct_gt*
    #     done
    # fi

    # if [[ ${step_ind} -eq 14 ]]; then
    #     for ind in ${inds[@]}
    #     do
    #         # check if struct_stage3 and angio_stage3 exist
    #         if [ ! -f "${recon_path}/scan_${ind}/angio_gt.nii.gz" ]; then
    #             echo "${recon_path}/scan_${ind}/angio_gt does not exist"
    #             continue
    #         fi
    #         if [ ! -f "${recon_path}/scan_${ind}/angio_stage3.nii.gz" ]; then
    #             echo "${recon_path}/scan_${ind}/angio_stage3 does not exist"
    #             continue
    #         fi
    #     done
    # fi
done
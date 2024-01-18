# Define the parameters for the reconstruction pipeline
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
code_path="/home/fs0/qijia/code/moco/"
# date: "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2"
# date="28-11-23"
for date in "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2"
do
    echo "date: ${date}"
    
    mov_inds=(1 2)  # moving scan index
    static_ind=3    # static scan index
    inds=(${mov_inds[@]} ${static_ind[@]})


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

    step_ind=11
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
        for i in ${inds[@]}
        do
            fpath="${perf_recon_path}/scan_${i}"
            flist=($(ls -1 ${fpath}/*anat0.mat))
            echo ${flist}
            ./qsens -n 1000 -t 0.001 -q short.q ${flist[0]}
        done
        for i in ${inds[@]}
        do
            fpath="${recon_path}/scan_${i}"
            flist=($(ls -1 ${fpath}/*anat0.mat))
            echo ${flist}
            ./qsens -n 1000 -t 0.001 -q short.q ${flist[0]}
        done
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
        for ind in ${mov_inds[@]}
        do
            # perf recon
            SUBCMD="flirt -in ${perf_recon_path}/scan_${ind}/anat0 -ref ${perf_recon_path}/scan_${static_ind}/anat0 -out ${perf_recon_path}/scan_${ind}/anat0_reg -omat ${perf_recon_path}/scan_${ind}/anat0_regxfm -dof 6 -interp spline"
            echo $SUBCMD >> ${code_path}/parallel_scritps/register_anat_script0
            # recon
            SUBCMD="flirt -in ${recon_path}/scan_${ind}/anat0 -ref ${recon_path}/scan_${static_ind}/anat0 -out ${recon_path}/scan_${ind}/anat0_reg -omat ${recon_path}/scan_${ind}/anat0_regxfm -dof 6 -interp spline"
            echo $SUBCMD >> ${code_path}/parallel_scritps/register_anat_script0
        done

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
        for ind in ${mov_inds[@]}
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
        for ind in ${mov_inds[@]}
        do
            bash ${code_path}/example_scripts/stage1.sh ${perf_recon_path}/scan_${ind}
        done
    fi

    # 6. subspace reconstruct stage2 for scan_1 and scan_2
    if [[ ${step_ind} -eq 6 ]]; then
        for ind in ${mov_inds[@]}
        do
            subfolder="scan_${ind}"
            paramfname="${code_path}/example_scripts/subspace_param_stage2.m"
            basname="${perf_recon_path}/${subfolder}/subspace_motion_stage2/subspace_repeat"
            outname="${perf_recon_path}/${subfolder}/subspace_motion_stage2_combined"
            # 6.1. parallel subspace recon
            rm ${perf_recon_path}/${subfolder}/recon_subspace_script_n2
            for i in {1..98}
            do
                SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};p.shot_ind=${i};sim_invivo_motion('${paramfname}',p)"
                echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/${subfolder}/recon_subspace_script_n2
            done

            CMD="$FSLSUBCMD -q short.q -s openmp,4 -t ${perf_recon_path}/${subfolder}/recon_subspace_script_n2"
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
        for ind in ${mov_inds[@]}
        do
            bash ${code_path}/example_scripts/stage2.sh ${perf_recon_path}/scan_${ind}
        done
    fi

    # 8. reconstruct anat with mcf for scan_1 and scan_2
    if [[ ${step_ind} -eq 8 ]]; then
        # rm ${perf_recon_path}/scan_${ind}/recon_anat_script2
        for ind in ${mov_inds[@]}
        do
            paramfname="${code_path}/example_scripts/anat_param_stage2.m"
            mcf_mat="${perf_recon_path}/scan_${ind}/subspace_motion_stage2_combined_masked_flirt.mat"
            SUBCMD="cd('${code_path}');include_path();p.date='${date}';p.ind=${ind};p.mcf_mat='${mcf_mat}';sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" > ${perf_recon_path}/scan_${ind}/recon_anat_script2
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

    # 9. register anat with mcf to scan_3, angio/ perfusion
    if [[ ${step_ind} -eq 9 ]]; then
        for ind in ${mov_inds[@]}
        do
            # perf recon
            SUBCMD="flirt -in ${perf_recon_path}/scan_${ind}/anat2 -ref ${perf_recon_path}/scan_${static_ind}/anat0 -out ${perf_recon_path}/scan_${ind}/anat2_reg -omat ${perf_recon_path}/scan_${ind}/anat2_regxfm -dof 6"
            CMD="$FSLSUBCMD -q short.q $SUBCMD"
            ID=$(eval $CMD)
            # recon
            SUBCMD="flirt -in ${recon_path}/scan_${ind}/anat2 -ref ${recon_path}/scan_${static_ind}/anat0 -out ${recon_path}/scan_${ind}/anat2_reg -omat ${recon_path}/scan_${ind}/anat2_regxfm -dof 6"
            CMD="$FSLSUBCMD -q short.q $SUBCMD"
            ID=$(eval $CMD)
        done
    fi


    # 10. add additional xfm and to flirt matrix stage 2
    if [[ ${step_ind} -eq 10 ]]; then
        for ind in ${mov_inds[@]}
        do
            bash ${code_path}/example_scripts/stage3.sh ${perf_recon_path}/scan_${ind} ${recon_path}/scan_${ind}
        done
    fi

    # 11. reconstruct anat with mcf for scan_1 and scan_2 check stage3 converted xfm
    if [[ ${step_ind} -eq 11 ]]; then
        # rm ${perf_recon_path}/scan_${ind}/recon_anat_script3
        for ind in ${mov_inds[@]}
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

        for ind in ${mov_inds[@]}
        do
            subfolder="scan_${ind}"
            rm ${perf_recon_path}/${subfolder}/recon_perf_script3
            rm ${recon_path}/${subfolder}/recon_angio_script3

            # perfusion
            paramfname="${code_path}/example_scripts/perfusion_param_gt.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${perf_recon_path}/scan_${ind}/anat2_regxfm';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/${subfolder}/recon_perf_script3

            mcf_mat="${perf_recon_path}/scan_${ind}/subspace_motion_stage3_combined_masked_flirt.mat"
            paramfname="${code_path}/example_scripts/perfusion_param_stage3.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" >> ${perf_recon_path}/${subfolder}/recon_perf_script3

            # CMD="$FSLSUBCMD -q short.q -s openmp,8 -t ${perf_recon_path}/${subfolder}/recon_perf_script3"
            # ID=$(eval $CMD)

            # angio and struct
            paramfname="${code_path}/example_scripts/angio_param_gt.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${recon_path}/scan_${ind}/anat2_regxfm';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            # echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

            mcf_mat="${recon_path}/scan_${ind}/subspace_motion_stage3_combined_masked_flirt.mat"
            paramfname="${code_path}/example_scripts/angio_param_stage3.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            # echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

            paramfname="${code_path}/example_scripts/struct_param_gt.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${recon_path}/scan_${ind}/anat2_regxfm';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

            mcf_mat="${recon_path}/scan_${ind}/subspace_motion_stage3_combined_masked_flirt.mat"
            paramfname="${code_path}/example_scripts/struct_param_stage3.m"
            SUBCMD="cd('${code_path}');p.mcf_mat='${mcf_mat}';p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
            echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

            CMD="$FSLSUBCMD -q short.q -s openmp,10 -t ${recon_path}/${subfolder}/recon_angio_script3"
            ID=$(eval $CMD)

        done

        # static scan
        ind=${static_ind}
        subfolder="scan_${ind}"
        rm ${perf_recon_path}/${subfolder}/recon_perf_script3
        rm ${recon_path}/${subfolder}/recon_angio_script3

        paramfname="${code_path}/example_scripts/perfusion_param_gt.m"
        SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
        echo $MATLABCMD \"$SUBCMD\" > ${perf_recon_path}/${subfolder}/recon_perf_script3

        paramfname="${code_path}/example_scripts/angio_param_gt.m"
        SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
        # echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

        paramfname="${code_path}/example_scripts/struct_param_gt.m"
        SUBCMD="cd('${code_path}');p.date='${date}';p.ind=${ind};sim_invivo_motion('${paramfname}',p)"
        echo $MATLABCMD \"$SUBCMD\" >> ${recon_path}/${subfolder}/recon_angio_script3

        # CMD="$FSLSUBCMD -q short.q -s openmp,8 -t ${perf_recon_path}/${subfolder}/recon_perf_script3"
        # ID=$(eval $CMD)

        CMD="$FSLSUBCMD -q short.q -s openmp,10 -t ${recon_path}/${subfolder}/recon_angio_script3"
        ID=$(eval $CMD)

    fi
done
# 1. Vessel extraction
#    generate vessel mask from .nii.gz file
# date="22-11-22"
FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
script_path=""
for date in "9-2-23" "13-2-23" "15-2-23" "17-2-23" "22-11-22"
do
    echo $date
    est_type=3
    if [[ ${est_type} -eq 0 ]]; then
        fpath="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_${date}/meas_cone_144_capria_12_lambda0.1.nii.gz"
        SUBCMD="p.thresh1=30; p.thresh2=0.1; gen_angio_mask(${fpath}, p);"
        echo $MATLABCMD \"$SUBCMD\" >> ${script_path}
        CMD="$FSLSUBCMD -q short.q -t ${script_path}"
        ID=$(eval $CMD)
    fi

    # 2. estimate parallel

    if [[ ${est_type} -eq 1 ]]; then
        #    subspace
        # capria_modelfit_parallel_subspace 
        script_path="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_${date}/"
        fpath="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_${date}/meas_cone_144_subspace_Nt144_Nk12_randomdict_L_balance_0_lambda_0.0005.mat"
        SUBCMD="capria_modelfit_parallel_subspace('$fpath');"
        echo $MATLABCMD \"$SUBCMD\" >> ${script_path}
        CMD="$FSLSUBCMD -q short.q -s openmp,2 -t "

        ext=".mat"
        rep="_AngioFitting"
        outpath="${fpath/${ext}/${rep}}"
        cd outpath
        bash parallel_script.sh
    fi

    if [[ ${est_type} -eq 2 ]]; then
        #    capria
        # capria_modelfit_parallel
        # fpath=['/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_' char(date) '/meas_cone_144_capria_12_lambda0.1.nii.gz'];              
        SUBCMD="capria_modelfit_parallel(fpath);"
    fi

    if [[ ${est_type} -eq 3 ]]; then
        outpath="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_${date}/meas_cone_144_subspace_Nt144_Nk12_randomdict_L_balance_0_lambda_0.0005_AngioFitting"
        cd $outpath
        bash parallel_script.sh
        outpath="/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_${date}/meas_cone_144_capria_12_lambda0.1_AngioFitting"
        cd $outpath
        bash parallel_script.sh
    fi

    if [[ ${est_type} -eq 4 ]]; then
        #    capria
        # capria_modelfit_parallel
        # fpath=['/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_' char(date) '/meas_cone_144_capria_12_lambda0.1.nii.gz'];              
        SUBCMD="capria_modelfit_parallel(fpath);"
    fi

done
sens_name="/vols/Data/okell/qijia/perf_recon_12-10-23/meas_MID00023_FID32357_to_CV_VEPCASL_v0p6_qijia_36x49_176_164Hz_vFA_sens1"
matdir="/vols/Data/okell/qijia/perf_recon_12-10-23/subspace_1_combined_new_brain_mcf.mat"
outdir="/vols/Data/okell/qijia/perf_recon_12-10-23/sens_1_mcf/"

FSLSUBCMD="$FSLDIR/bin/fsl_sub -m n -l logs"
MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
mkdir ${outdir}

# 1. split sens to imag and real part nifti
SUBCMD="split_sens\(\'${sens_name}\'\)"
CMD="$FSLSUBCMD -q veryshort.q $MATLABCMD \"$SUBCMD\""
ID=$(eval $CMD)

# 2. rotate the real and imag part of sensitivity maps
rm flirt_sens_4d_script
for i in {1..98}
do
    matname="$( printf "MAT_%04d" $(( i-1 )) )"
    SUBCMD="applyxfm4D ${sens_name}_real ${sens_name}_real ${outdir}/sens_real_${i} ${matdir}/${matname} --singlematrix"
    echo $SUBCMD >> flirt_sens_4d_script
    SUBCMD="applyxfm4D ${sens_name}_imag ${sens_name}_imag ${outdir}/sens_imag_${i} ${matdir}/${matname} --singlematrix"
    echo $SUBCMD >> flirt_sens_4d_script
done

CMD="$FSLSUBCMD -j ${ID} -q veryshort.q -t flirt_sens_4d_script"
ID=$(eval $CMD)

# 3. combine the real and imag part of sensitivity maps
rm combine_sens_script
for i in {1..98}
do
    realname="${outdir}/sens_real_${i}.nii.gz"
    imagname="${outdir}/sens_imag_${i}.nii.gz"
    SUBCMD="combine_sens('${realname}','${imagname}','${outdir}/sens_${i}')"
    echo $MATLABCMD \"$SUBCMD\" >> combine_sens_script
done

CMD="$FSLSUBCMD -j ${ID} -q veryshort.q -t combine_sens_script"
ID=$(eval $CMD)

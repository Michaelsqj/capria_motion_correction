# MATLABCMD="/opt/fmrib/MATLAB/R2021a/bin/matlab -nojvm -nodisplay -r"
# for i in {1..128}
# do
#     fsl_sub -q short.q -s openmp,12 -l logs ${MATLABCMD} \"espirit_estimate\(${i}\)\"
# done
date="23-11-23"
ind=1
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
recon_dir="${script_dir}/../external/MChiewCAPRIARecon"
fpath="/vols/Data/okell/qijia/perf_recon_${date}/scan_${ind}"
flist=($(ls -1 ${fpath}/*anat.mat))
echo ${flist}
cd "${recon_dir}"
./qsens -n 1000 -t 0.001 -q short.q ${flist[0]}

# sens estimate for t1
fpath="/vols/Data/okell/qijia/raw_data_${date}"
flist=($(ls -1 ${fpath}/*anat.mat))
echo ${flist}
cd "${recon_dir}"
./qsens -n 1000 -t 0.001 -q veryshort.q ${flist[0]}

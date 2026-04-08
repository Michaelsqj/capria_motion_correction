#!/bin/bash
#
# recon_angio_no_moco.sh
# ======================
# Reconstruct CAPRIA angiography images from raw Siemens k-space data
# without motion correction.
#
# Pipeline:
#   Step 1 - Reconstruct anatomical image (Stage 0) for coil sensitivity estimation
#   Step 2 - Estimate coil sensitivity maps via qsens
#   Step 3 - Reconstruct angiography (no motion correction)
#
# Required environment variables (set these before running):
#   CODE_PATH      - absolute path to the repository root
#   RAW_DATA_PATH  - absolute path to the raw k-space data directory
#                    (must contain matchfile.m and a ktraj/ subdirectory)
#   RECON_PATH     - absolute path for reconstruction outputs
#   SCAN_IND       - scan index within matchfile.m (e.g. 1, 2, 3)
#   MATLAB_CMD     - MATLAB command  (e.g. "matlab -batch")
#
# Example:
#   export CODE_PATH=/home/user/capria_motion_correction
#   export RAW_DATA_PATH=/data/raw/raw_data_28-11-23
#   export RECON_PATH=/data/recon/recon_28-11-23
#   export SCAN_IND=1
#   export MATLAB_CMD="matlab -batch"
#   bash example_scripts/recon_angio_no_moco.sh
#

set -euo pipefail

# --- Validate required environment variables ---
: "${CODE_PATH:?Set CODE_PATH to the repository root}"
: "${RAW_DATA_PATH:?Set RAW_DATA_PATH to the raw data directory}"
: "${RECON_PATH:?Set RECON_PATH to the output directory}"
: "${SCAN_IND:?Set SCAN_IND to the scan index}"
: "${MATLAB_CMD:?Set MATLAB_CMD to the matlab command (e.g. 'matlab -batch')}"

SCAN_DIR="${RECON_PATH}/scan_${SCAN_IND}"
mkdir -p "${SCAN_DIR}"

echo "========================================================"
echo " CAPRIA Angiography Reconstruction (no motion correction)"
echo "========================================================"
echo " Code path:    ${CODE_PATH}"
echo " Raw data:     ${RAW_DATA_PATH}"
echo " Output:       ${SCAN_DIR}"
echo " Scan index:   ${SCAN_IND}"
echo "========================================================"

# -----------------------------------------------------------------------
# Step 1: Reconstruct anatomical image for coil sensitivity estimation
# -----------------------------------------------------------------------
# Performs a per-coil gridding reconstruction (recon_type=8) using the
# final two inversion-time (TI) segments of the k-space. Outputs:
#   anat0.nii.gz  - sum-of-squares magnitude image (visual QC)
#   anat0.mat     - per-coil images (input to qsens in Step 2)
# -----------------------------------------------------------------------
echo ""
echo "[Step 1/3] Reconstructing anatomical image..."

PARAM_ANAT="${CODE_PATH}/example_scripts/angio_param_no_moco_anat.m"
MATLAB_SUBCMD="cd('${CODE_PATH}'); include_path(); p.fpath='${RAW_DATA_PATH}/'; p.outpath='${SCAN_DIR}/'; p.ind=${SCAN_IND}; sim_invivo_motion('${PARAM_ANAT}', p);"
${MATLAB_CMD} "${MATLAB_SUBCMD}"

echo "[Step 1/3] Done. Output: ${SCAN_DIR}/anat0.{nii.gz,mat}"

# -----------------------------------------------------------------------
# Step 2: Estimate coil sensitivity maps
# -----------------------------------------------------------------------
# Runs SENSE1-based iterative sensitivity estimation on the per-coil
# anatomical images stored in anat0.mat.
#   -n 1000  : number of iterations
#   -t 0.001 : regularisation threshold
# Output: sens0.mat
# -----------------------------------------------------------------------
echo ""
echo "[Step 2/3] Estimating coil sensitivity maps..."

ANAT_MAT="${SCAN_DIR}/anat0.mat"
if [ ! -f "${ANAT_MAT}" ]; then
    echo "Error: ${ANAT_MAT} not found. Did Step 1 complete successfully?"
    exit 1
fi

QSENS_DIR="${CODE_PATH}/external/MChiewCAPRIARecon"
pushd "${QSENS_DIR}" > /dev/null
./qsens -n 1000 -t 0.001 "${ANAT_MAT}"
popd > /dev/null

SENS_MAT="${SCAN_DIR}/sens0.mat"
if [ ! -f "${SENS_MAT}" ]; then
    echo "Error: ${SENS_MAT} not found. Did qsens run successfully?"
    exit 1
fi

echo "[Step 2/3] Done. Output: ${SCAN_DIR}/sens0.mat"

# -----------------------------------------------------------------------
# Step 3: Reconstruct angiography (without motion correction)
# -----------------------------------------------------------------------
# Reconstructs the dynamic (12-phase) angiography difference image using
# POGM with Locally Low Rank (LLR) regularisation.
# No mcf_mat is provided, so no motion correction is applied.
# Output: angio_no_moco.nii.gz
# -----------------------------------------------------------------------
echo ""
echo "[Step 3/3] Reconstructing angiography (no motion correction)..."

PARAM_ANGIO="${CODE_PATH}/example_scripts/angio_param_no_moco.m"
MATLAB_SUBCMD="cd('${CODE_PATH}'); include_path(); p.fpath='${RAW_DATA_PATH}/'; p.outpath='${SCAN_DIR}/'; p.ind=${SCAN_IND}; sim_invivo_motion('${PARAM_ANGIO}', p);"
${MATLAB_CMD} "${MATLAB_SUBCMD}"

echo "[Step 3/3] Done. Output: ${SCAN_DIR}/angio_no_moco.nii.gz"
echo ""
echo "Reconstruction complete."

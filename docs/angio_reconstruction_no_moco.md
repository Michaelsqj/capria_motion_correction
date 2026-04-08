# Angiography Reconstruction Without Motion Correction

## Overview

This guide describes how to reconstruct CAPRIA angiography images from raw Siemens k-space data without motion correction. This is the simplest reconstruction pipeline and produces the baseline image before any motion correction is applied.

The output is a 4D angiography difference image (tag − control) over 12 temporal phases at full spatial resolution (186 × 196 × 150 voxels).

## Pipeline Summary

```
Raw k-space (.dat)
       │
       ▼
[Step 1] Anatomical reconstruction (recon_type=8, gridding)
         anat0.nii.gz, anat0.mat
       │
       ▼
[Step 2] Coil sensitivity estimation (qsens)
         sens0.mat
       │
       ▼
[Step 3] Angiography reconstruction (recon_type=0, POGM-LLR)
         angio_no_moco.nii.gz
```

## Prerequisites

### Software

- **MATLAB** (R2021a or later)
- **FSL** — for the `qsens` sensitivity estimation binary
- **Repository external dependencies** (bundled in `external/`):
  - `mapVBVD` — Siemens raw data reader
  - `irt` — iterative reconstruction toolbox (NUFFT, density compensation)
  - `MChiewCAPRIARecon` — provides the `qsens` binary

### Data Layout

The raw data directory (`RAW_DATA_PATH`) must contain:

| File / Directory | Description |
|------------------|-------------|
| `matchfile.m` | MATLAB script defining per-scan metadata (measurement IDs, gradient filenames, dead ADC points) indexed by scan index |
| `ktraj/` | Gradient trajectory files referenced in `matchfile.m` |
| `meas_*.dat` | Siemens raw k-space measurement files |

## Usage

### 1. Set environment variables

```bash
export CODE_PATH=/path/to/capria_motion_correction   # repository root
export RAW_DATA_PATH=/path/to/raw_data_28-11-23      # raw k-space data directory
export RECON_PATH=/path/to/recon_output              # reconstruction output directory
export SCAN_IND=3                                    # scan index in matchfile.m
export MATLAB_CMD="matlab -batch"                    # MATLAB executable + mode flag
```

### 2. Run

```bash
bash example_scripts/recon_angio_no_moco.sh
```

### 3. Outputs

All outputs are written to `${RECON_PATH}/scan_${SCAN_IND}/`:

| File | Description |
|------|-------------|
| `anat0.nii.gz` | Anatomical image (sum-of-squares, for visual QC) |
| `anat0.mat` | Per-coil anatomical images (input to `qsens`) |
| `sens0.mat` | Estimated coil sensitivity maps |
| `angio_no_moco.nii.gz` | Angiography difference image (12 temporal phases) |

## Step-by-Step Details

### Step 1 — Anatomical Image Reconstruction

**Parameter file:** [`example_scripts/angio_param_no_moco_anat.m`](../example_scripts/angio_param_no_moco_anat.m)

**Entry point:** `sim_invivo_motion(param_file, p)`

Reconstructs an anatomical image from the raw k-space data using per-coil gridding (`recon_type=8`). Only the last two inversion-time (TI) segments are used — at late TI, the background tissue signal dominates, giving a good anatomical reference for sensitivity estimation.

Key parameters:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `recon_type` | 8 | Gridding reconstruction for anatomical image |
| `kspace_cutoff` | 1 | Full k-space (no resolution reduction) |
| `recon_shape` | [186, 196, 150] | Output image dimensions |
| `compress` | 1 | PCA-based coil compression to 8 virtual coils |

The reconstruction calls `loadData()` which:
1. Reads the measurement file via `mapVBVD` (identified by `matchfile.m`)
2. Generates the 3D kooshball k-space trajectory using the golden-ratio rotation angles stored in the ICE parameters
3. Applies coil compression (PCA to 8 virtual coils) if `compress=1`

### Step 2 — Coil Sensitivity Estimation

**Tool:** `external/MChiewCAPRIARecon/qsens`

Runs iterative SENSE1-based sensitivity estimation on the per-coil anatomical images in `anat0.mat`. The output `sens0.mat` contains sensitivity maps of shape `[Nx, Ny, Nz, NCoils]` which are used to combine coil images during reconstruction.

```
./qsens -n 1000    # 1000 iterations
        -t 0.001   # regularisation threshold
        anat0.mat
```

### Step 3 — Angiography Reconstruction

**Parameter file:** [`example_scripts/angio_param_no_moco.m`](../example_scripts/angio_param_no_moco.m)

**Entry point:** `sim_invivo_motion(param_file, p)`

Reconstructs the dynamic angiography difference image. The reconstruction:

1. Loads the full k-space data (tag and control, `Navgs=2`)
2. Computes `add_motion()` — since no motion parameters are set, this is a no-op and k-space/images are passed through unchanged
3. Skips motion correction — no `mcf_mat` is set
4. Calls `reconstruct()` with `recon_type=0`

Inside `reconstruct()` with `recon_type=0, optalg="pogm_LLR_match"`:
- Builds two NUFFT operators `E1` (tag) and `E2` (control) over `Nt=12` temporal phases
- Computes adjoint images `dd1 = E1' * kd1` and `dd2 = E2' * kd2`
- Solves `min ||x||_LLR  s.t.  E1*x ≈ kd1, E2*x ≈ kd2` jointly via POGM, then returns `x1 - x2`

Key reconstruction parameters:

| Parameter | Value | Description |
|-----------|-------|-------------|
| `recon_type` | 0 | Angiography difference image (tag − control) |
| `Nt` | 12 | Number of temporal angiographic phases |
| `optalg` | `"pogm_LLR_match"` | POGM with LLR, tag and control reconstructed jointly |
| `lambda` | 7e-2 | LLR regularisation strength |
| `patch_size` | [5, 5, 5] | Spatial patch size for LLR |
| `niter` | 200 | Number of POGM iterations |
| `kspace_cutoff` | 1 | Full k-space resolution |

## Relationship to the Full Motion Correction Pipeline

This pipeline corresponds to reconstructing the **static reference scan** (typically `scan_3`) in [`example_scripts/recon_pipeline.sh`](../example_scripts/recon_pipeline.sh) (Step 12, static scan branch). It produces the "before correction" baseline image that is compared against the motion-corrected output.

To add motion correction, a motion correction matrix (`mcf_mat`) must be estimated from a separate iterative pipeline (Steps 1–11 in `recon_pipeline.sh`) and passed via `p.mcf_mat` when calling `sim_invivo_motion`. See [`example_scripts/angio_param_stage3.m`](../example_scripts/angio_param_stage3.m) for the motion-corrected equivalent.

## Troubleshooting

**`matchfile` not found / `cd` error in `loadData`:**
Ensure `RAW_DATA_PATH` points to the directory that directly contains `matchfile.m`.

**`qsens` not executable:**
Check that the binary exists and is compiled: `ls -la external/MChiewCAPRIARecon/qsens`. It requires FSL to be sourced (`source $FSLDIR/etc/fslconf/fsl.sh`).

**MATLAB path errors (`include_path` missing):**
Run from `CODE_PATH` or ensure the `cd('${CODE_PATH}')` at the start of the MATLAB command succeeds. `include_path()` adds all necessary toolbox paths.

**Sensitivity map shape mismatch:**
If the reconstructed image and sensitivity map dimensions disagree, check that `recon_shape` in the parameter file matches the shape used during sensitivity estimation.

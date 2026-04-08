# CAPRIA Motion Correction — Repo Overview

## What this repo is

MATLAB/Python codebase for **CAPRIA (Combined Angiography and Perfusion using Radial Imaging and Arterial spin labelling) MRI reconstruction with motion correction**. The main goal is to reconstruct high-quality angiography and perfusion images from 3D radial k-space data acquired on Siemens scanners, with or without retrospective motion correction.

- **Institution:** FMRIB / Okell group, University of Oxford
- **User:** Qijia (PhD student / researcher)
- **Git remote:** https://github.com/Michaelsqj/capria_motion_correction

---

## Directory layout

```
capria_motion_correction/
├── example_scripts/          # Shell + MATLAB param files for each pipeline stage
│   ├── recon_angio_no_moco.sh          ← baseline angio recon (no MCo) — NEW
│   ├── angio_param_no_moco_anat.m      ← Stage 0 params for above — NEW
│   ├── angio_param_no_moco.m           ← Stage 3 params for above — NEW
│   ├── recon_pipeline.sh               ← full motion-correction pipeline (master script)
│   ├── recon_pipeline4.sh              ← gridding-based MCo variant
│   ├── anat_param_stage0.m / anat_angi_param_stage0.m  ← Stage 0 params
│   ├── angio_param_stage3*.m           ← Stage 3 angio params (various MCo variants)
│   ├── perfusion_param_*.m             ← Stage 1/2/3 perfusion params
│   ├── subspace_param_stage*.m         ← Subspace recon params for MCo estimation
│   ├── stage1.sh / stage2.sh / stage3.sh  ← intermediate MCo pipeline steps
│   └── ...
├── docs/
│   └── angio_reconstruction_no_moco.md ← step-by-step doc for baseline angio — NEW
├── external/                 # Vendored dependencies
│   ├── mapVBVD/              ← Siemens raw data reader
│   ├── irt/                  ← Iterative reconstruction toolbox (NUFFT, etc.)
│   ├── MChiewCAPRIARecon/    ← qsens binary + legacy helpers
│   ├── CAPRIAModel/          ← ASL signal model fitting
│   └── ...
├── recon_utils/
│   └── reconstruct.m         ← central dispatch: recon_type 0-10 (see below)
├── motion_utils/
│   ├── add_motion.m          ← applies motion params to k-space (no-op if none set)
│   └── add_motion_mat2.m     ← applies FSL-format 4×4 matrices to k-space
├── sens_estimate/            ← coil sensitivity estimation utilities
├── subspace_utils/           ← subspace / low-rank reconstruction helpers
├── traj_utils/               ← k-space trajectory utilities
├── rotation_utils/           ← 3D rotation math
├── analysis/                 ← post-recon analysis (model fitting, vessel masks, etc.)
├── sigpy_recon/              ← Python sigpy-based reconstruction (alternative)
├── sim_invivo_motion.m       ← MAIN ENTRY POINT for reconstruction
├── loadData.m                ← raw data loading + k-traj generation
├── include_path.m            ← adds all toolbox paths to MATLAB path
├── calc_psens.m              ← PCA-based coil compression
└── apply_sens_xfm.m          ← applies coil compression transform
```

---

## Key data concepts

- **Sequence:** 3D radial kooshball (golden-ratio rotations), tag+control (Navgs=2), multiple repeats (Nshots)
- **Raw data:** Siemens `.dat` files read via `mapVBVD`; trajectory angles stored in ICE parameters
- **matchfile.m:** per-dataset MATLAB script in the raw data directory; defines `gradnames`, `measIDs`, `dead_ADC_ptss` etc. indexed by scan index (`ind`)
- **Scan index (`ind`):** indexes into matchfile; a session typically has 3 scans (scan_1, scan_2 = moving; scan_3 = static reference)
- **Two recon paths per session:**
  - `recon_<date>/scan_<ind>/` — angio/struct recon
  - `perf_recon_<date>/scan_<ind>/` — perfusion recon

---

## Main entry point: `sim_invivo_motion.m`

```matlab
sim_invivo_motion(param_fpath, p)
```

1. Runs the parameter `.m` file (sets fields on `p`)
2. Calls `loadData(p.ind, p.fpath, p)` → returns `kdata, ktraj, image, kspace`
3. Calls `add_motion(kspace, image, p)` → applies synthetic/in-vivo motion (no-op if no motion params set)
4. If `p.mcf_mat` is set → calls `add_motion_mat2` to apply FSL-format motion correction matrices
5. Calls `reconstruct(new_kspace, new_image, p)` → returns image `rd`
6. Saves output via `save_avw`

**Without motion correction:** call without setting `p.mcf_mat`. `add_motion` becomes a no-op.

---

## `reconstruct.m` — recon_type dispatch

| `recon_type` | Purpose |
|---|---|
| 0 | **Angiography difference image** (tag − control), NUFFT + POGM-LLR |
| 1 | Gridding or CG-SENSE for all repeats |
| 2 | Subspace recon for all repeats (BART or POGM) |
| 3 | Subspace recon per-repeat (motion estimation use) |
| 8 | **Anatomical image** (gridding, last 2 TI segs) → for coil sensitivity |

**Key `optalg` values for recon_type=0:**
- `"pogm_LLR_match"` — tag & control jointly reconstructed (no/minimal motion, ground truth)
- `"pogm_LLR_split"` — tag & control reconstructed separately (motion between them)
- `"pogm_LLR_mismatch"` — explicit mismatch model

---

## Pipeline: baseline angio reconstruction (no MCo)

Files: `example_scripts/recon_angio_no_moco.sh` + param files

```
Step 1  sim_invivo_motion(angio_param_no_moco_anat.m)   recon_type=8  → anat0.{nii.gz,mat}
Step 2  external/MChiewCAPRIARecon/qsens anat0.mat                    → sens0.mat
Step 3  sim_invivo_motion(angio_param_no_moco.m)         recon_type=0  → angio_no_moco.nii.gz
```

All paths come from env vars: `CODE_PATH`, `RAW_DATA_PATH`, `RECON_PATH`, `SCAN_IND`, `MATLAB_CMD`.

---

## Full motion-correction pipeline (`recon_pipeline.sh`) — 12 steps

| Step | Action |
|---|---|
| 1 | Reconstruct anat (Stage 0) for all scans → `anat0.mat` |
| 2 | Estimate coil sensitivities via `qsens` → `sens0.mat` |
| 3 | Register anat images across scans (FLIRT) |
| 4-5 | Subspace recon Stage 1 (parallel, per-shot) + MCFlirt |
| 6-7 | Subspace recon Stage 2 + MCFlirt |
| 8 | Reconstruct anat with Stage 2 MCo matrices |
| 9 | Register motion-corrected anat |
| 10 | Combine FSL transforms (`convert_xfm -concat`) |
| 11 | Validate combined transforms via anat recon |
| 12 | Final angio/perfusion/struct recon with MCo |

---

## Coil sensitivity estimation

- **Primary tool:** `external/MChiewCAPRIARecon/qsens -n 1000 -t 0.001 <anat0.mat>` (requires FSL)
  - Input: `anat0.mat` (field `m`: per-coil images)
  - Output: `sens0.mat` (field `sens`: [Nx,Ny,Nz,NCoils])
- **Alternatives:** `sens_estimate/bart_ecalib.m` (BART ESPIRiT), `sens_estimate/estimate_sens.py` (sigpy JSense)

---

## Conventions

- Parameter files are `.m` scripts that modify `p` struct fields; they live in `example_scripts/`
- Shell scripts for pipeline stages also live in `example_scripts/`
- Documentation (markdown) lives in `docs/`
- No hardcoded paths in new scripts — all paths via env vars
- `fullfile()` preferred over `+` string concat in param files (handles char vs string)
- `include_path()` must be called before any reconstruction function

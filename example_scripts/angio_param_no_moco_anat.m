% Anatomical image reconstruction parameters for coil sensitivity estimation
% (Stage 0, angiography pipeline without motion correction)
%
% Expected inputs set before this file is run (via sim_invivo_motion):
%   p.fpath    - path to raw data directory (must contain matchfile.m)
%   p.outpath  - path to output directory
%   p.ind      - scan index within matchfile.m

p.outfile           = fullfile(p.outpath, 'anat0');

p.compress          = 1;
p.kspace_cutoff     = 1;           % full k-space resolution
p.recon_shape       = [186, 196, 150];

% recon_type = 8: per-coil gridding reconstruction using the last two TI
%   segments, for subsequent sensitivity estimation.
% Outputs:
%   anat0.nii.gz  - sum-of-squares magnitude image (visual QC)
%   anat0.mat     - per-coil images (input to qsens in Step 2)
p.recon_type        = 8;

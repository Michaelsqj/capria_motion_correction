% Angiography reconstruction parameters (without motion correction)
%
% Expected inputs set before this file is run (via sim_invivo_motion):
%   p.fpath    - path to raw data directory (must contain matchfile.m)
%   p.outpath  - path to output directory
%   p.ind      - scan index within matchfile.m

p.outfile           = fullfile(p.outpath, 'angio_no_moco');
p.sens_path         = fullfile(p.outpath, 'sens0.mat');

p.Nt                = 12;          % number of temporal angiographic phases

p.compress          = 1;
p.kspace_cutoff     = 1;           % full k-space resolution
p.recon_shape       = [186, 196, 150];

% Reconstruction parameters
% recon_type = 0: angiography difference image (tag - control)
% optalg = "pogm_LLR_match": POGM with Locally Low Rank regularisation,
%   reconstructing tag and control jointly under a shared image prior.
% No mcf_mat is set, so no motion correction is applied.
p.recon_type        = 0;
p.optalg            = "pogm_LLR_match";
p.lambda            = 7e-2;
p.patch_size        = [5, 5, 5];
p.niter             = 200;

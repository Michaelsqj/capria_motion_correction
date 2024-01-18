p.fpath                     = "/vols/Data/okell/qijia/raw_data_" + p.date + "/"
p.outpath                   = "/vols/Data/okell/qijia/recon_" + p.date + "/scan_" + num2str(p.ind) + "/"
p.outfile                   = p.outpath  + "/anat3"


p.compress                  = 1;
p.kspace_cutoff             = 1;
p.recon_shape               = [186,196,150];

% motion parameters
p.mcf_mat                   = "/vols/Data/okell/qijia/recon_" + p.date + "/scan_" + num2str(p.ind) + "/subspace_motion_stage3_combined_masked_flirt.mat"


% recon parameters 
p.recon_type                = 8;

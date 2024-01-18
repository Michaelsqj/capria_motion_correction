p.fpath                     = "/vols/Data/okell/qijia/raw_data_" + p.date + "/"
p.outpath                   = "/vols/Data/okell/qijia/perf_recon_" + p.date + "/scan_" + num2str(p.ind) + "/subspace_motion_stage1/"
p.outfile                   = p.outpath  + "/subspace_repeat"
p.sens_path                 = "/vols/Data/okell/qijia/perf_recon_" + p.date + "/scan_" + num2str(p.ind)  + "/sens0.mat"

p.compress                  = 1;
p.kspace_cutoff             = 1/3;
p.recon_shape               = [62, 66, 50];

% motion parameters


% recon parameters 
p.recon_type                = 3;
p.subspace_path             = '/home/fs0/qijia/code/moco/subspace_utils/subspace_mat/subspace_T1_144_WE.mat';
p.Nk                        = 2;
p.lambda                    = 1e-2;
p.niter                     = 100;
p.patch_size                = [5, 5, 5];
p.balance_basis             = 0;
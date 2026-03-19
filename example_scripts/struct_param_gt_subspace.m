p.fpath                     = "/vols/Data/okell/qijia/raw_data_" + p.date + "/"
p.outpath                   = "/vols/Data/okell/qijia/recon_" + p.date + "/scan_" + num2str(p.ind) + "/"
p.outfile                   = p.outpath  + "/struct_gt"
p.sens_path                 = "/vols/Data/okell/qijia/recon_" + p.date + "/scan_" + num2str(p.ind)  + "/sens0.mat"

p.compress                  = 1;
p.kspace_cutoff             = 1;
p.recon_shape               = [186,196,150];



% motion parameters


% recon parameters 
p.recon_type                = 2;
p.subspace_path             = '/home/fs0/qijia/code/moco/subspace_utils/subspace_mat/subspace_T1_144_WE.mat';
p.Nk                        = 2;
p.lambda                    = 1e-4;
p.optalg                    = 'W';

p.save_complex              = true;
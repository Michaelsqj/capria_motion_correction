p.fpath                     = "/vols/Data/okell/qijia/raw_data_" + p.date + "/"
p.outpath                   = "/vols/Data/okell/qijia/perf_recon_" + p.date + "/scan_" + num2str(p.ind) + "/"
p.outfile                   = p.outpath  + "/struct_gt"
p.sens_path                 = "/vols/Data/okell/qijia/perf_recon_" + p.date + "/scan_" + num2str(p.ind)  + "/sens0.mat"

p.compress                  = 1;
p.kspace_cutoff             = 1/3;
p.recon_shape               = [62, 66, 50];

p.Nt                        = 6;

% motion parameters


% recon parameters 
p.recon_type                = 10;
p.optalg                    = "pogm_LLR_match"
p.lambda                    = 7e-2;
p.patch_size                = [5,5,5];
p.niter                     = 200;

p.save_complex              = true;
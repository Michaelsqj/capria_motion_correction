p.fpath                     = "/vols/Data/okell/qijia/raw_data_" + p.date + "/"
p.outpath                   = "/vols/Data/okell/qijia/recon_" + p.date + "/scan_" + num2str(p.ind) + "/"
p.outfile                   = p.outpath  + "/angio_stage3_5e-2"
p.sens_path                 = "/vols/Data/okell/qijia/recon_" + p.date + "/scan_" + num2str(p.ind)  + "/sens0.mat"

p.Nt                        = 12;

p.compress                  = 1;
p.kspace_cutoff             = 1;
p.recon_shape               = [186,196,150];



% motion parameters

% recon parameters 
p.recon_type                = 0;
p.optalg                    = "pogm_LLR_split"
p.lambda                    = 5e-2;
p.patch_size                = [5,5,5];
p.niter                     = 200;
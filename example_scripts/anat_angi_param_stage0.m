p.fpath                     = "/vols/Data/okell/qijia/raw_data_" + p.date + "/"
p.outpath                   = "/vols/Data/okell/qijia/recon_" + p.date + "/scan_" + num2str(p.ind) + "/"
p.outfile                   = p.outpath  + "/anat0"


p.compress                  = 1;
p.kspace_cutoff             = 1;
p.recon_shape               = [186,196,150];



% recon parameters 
p.recon_type                = 8;

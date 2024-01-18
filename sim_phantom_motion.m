function sim_phantom_motion(param_fpath)
    %-------------------------
    % This function is used to simulate motion from phantom
    % a phantom image will be loaded, the same image will be 
    % simulate k-space trajectory and motion
    % simulate reconstruction
    %-------------------------
    include_path()

    % set parameters
    setParam;   % set default parameters
    if ~exist(param_fpath,'file')
        error('parameter file not existed')
    else
       run(param_fpath) % overwrite default parameters
    end
    
    param_cells = namedargs2cell(p);
    
    % create ktraj
    [kspace, p] = create_kspace(p);   % [NCols, ninterleaves, 3]

    % load phantom image
    [img,~,scales,~,~]=read_avw(p.phantom_name);

    % NUFFT to kspace, generate kd
    imSize = size(img);
    ktraj = reshape(kspace, p.NCols*p.NLines, p.Nt, 3) ./ p.kmax .* pi;
%     ktraj = reshape(permute(ktraj,[1,2,3,4]), [], p.Nt,   3);
    E = xfm_NUFFT([imSize, 3], [],[],ktraj);
    kdata = 1./E.w.*(E*repmat(img, 1,1,1,3));

    % add signal modulation


    % % add motion, rotation and translation
    % rng(1);
    % thetas = rand(2,nphases,3) * 0;
    % rng(2);
    % translations = rand(2,nphases,3) * 0;
    

    % reconstruction
    rd = reshape(E'*(E.w.*kdata), [E.Nd, E.Nt]);
    save_avw(abs(rd), [p.outpath, p.outfname], 'd', scales);

end
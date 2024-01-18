function sim_invivo_motion(param_fpath)

%     param_fpath = ''/home/fs0/qijia/scratch/moco_exp/params/subspace_param_15-6-23_1.m''

    include_path()
    % set parameters
    if ~exist(param_fpath,'file')
        error('parameter file not existed')
    else
        run(param_fpath) % overwrite default parameters
    end
    mkdir(p.outpath)

    % load data
    % image: NCols, Nsegs*NPhases, Nshots, Navgs, NCoils
    % kspace: NCols, Nsegs*NPhases, Nshots, 3
    [kdata, ktraj, p, image, kspace, base_k,] = loadData(p.ind, p.fpath, p);

    % load subspace principal components
    new_image = zeros(size(image));
    new_kspace = zeros([size(kspace, 1,2,3), p.Navgs, size(kspace,4)]);

    % add motion, rotation and translation
    rng(p.seed(1));
    rnd = rand(2,p.Nshots,3);
    thetas = (rnd(1,:,:) - 0.5) * p.rot_rng;
    translations =  (rnd(2,:,:) - 0.5) * p.tnsl_range;

    kspace = kspace * p.kmax / pi;
    [new_kspace1, new_image1] = add_motion(reshape(kspace,[],p.Nshots,3),...
                                            reshape(image(:,:,:,1,:),[],p.Nshots,p.NCoils),...
                                            squeeze(thetas),...
                                            squeeze(translations));
    rng(p.seed(2));
    rnd = rand(2,p.Nshots,3);
    thetas = (rnd(1,:,:) - 0.5) * p.rot_rng;
    translations =  (rnd(2,:,:) - 0.5) * p.tnsl_range;
    [new_kspace2, new_image2] = add_motion(reshape(kspace,[],p.Nshots,3),...
                                            reshape(image(:,:,:,2,:),[],p.Nshots,p.NCoils),...
                                            squeeze(thetas),...
                                            squeeze(translations));
    new_kspace(:,:,:,1,:) = reshape(new_kspace1, p.NCols, [], p.Nshots,3);
    new_kspace(:,:,:,2,:) = reshape(new_kspace2, p.NCols, [], p.Nshots,3);
    new_image(:,:,:,1,:) = reshape(new_image1, p.NCols, [], p.Nshots, p.NCoils);
    new_image(:,:,:,2,:) = reshape(new_image2, p.NCols, [], p.Nshots, p.NCoils);

    new_kspace = new_kspace / p.kmax * pi;

    %%
    rd = reconstruct(new_kspace, new_image, p);

    q=matfile(char(p.outfile),'Writable', true);
    q.m=rd(end:-1:1,end:-1:1,:,:);
    save_avw(abs(rd(end:-1:1,end:-1:1,:,:)), char(p.outfile), 'd', [1,1,1]*p.res);
end
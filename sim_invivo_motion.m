function sim_invivo_motion(param_fpath, p)
    %-------------------------
    % This function is used to simulate motion from phantom
    % a phantom image will be loaded
    % simulate k-space trajectory and motion
    % simulate reconstruction
    % p.ind = 1 2 3...
    % p.date = "23-11-23" etc.
    %-------------------------
    include_path()
    % set parameters
    if ~exist(param_fpath,'file')
        error('parameter file not existed')
    else
        [filepath,name,ext] = fileparts(param_fpath)
        cwd = pwd;
        cd(filepath)
        run([name,ext]) % overwrite default parameters
        cd(cwd)
    end
    mkdir(char(p.outpath))

    if isfield(p, 'shot_ind') && ~isempty(p.shot_ind)
        % p.shot_ind = shot_ind;
        for i = p.shot_ind
            p.outfile = sprintf('%s_%d', p.outfile, i);
        end
        % if isfile([p.outfile, '.nii.gz'])
        %     fprintf('file %s existed, skip\n', [p.outfile, '.nii.gz'])
        %     return
        % end
    end

    % if exist('ind','var')
    %     p.ind = ind;
    %     p.outfile = sprintf('%s_%d', p.outfile, ind);
    % end


    % if exist('rho','var') && ~isempty(rho)
    %     p.rho = rho;
    %     p.outfile = sprintf('%s_rho_%.0d', p.outfile, rho);
    % end

    % load data
    % image: NCols, Nsegs*NPhases, Nshots, Navgs, NCoils
    % kspace: NCols, Nsegs*NPhases, Nshots, 3, [-pi, pi]
    [kdata, ktraj, p, image, kspace, base_k,] = loadData(p.ind, p.fpath, p);
    kspace = kspace * p.kmax / pi;

    % add motion
    kspace = repmat(reshape(kspace, p.NCols, [], p.Nshots, 1, 3), [1,1,1,p.Navgs,1]);
    % image: NCols, Nsegs*NPhases, Nshots, Navgs, NCoils
    % kspace: NCols, Nsegs*NPhases, Nshots, Navgs, 3
    [new_kspace, new_image ] = add_motion(kspace, image, p);
    % new_image: NCols, Nsegs*NPhases, Nshots, Navgs, NCoils
    % new_kspace: NCols, Nsegs*NPhases, Nshots, Navgs, 3


    % % add motion, rotation and translation
    % rng(p.seed(1));
    % rnd = rand(2,p.Nshots,3);
    % thetas = (rnd(1,:,:) - 0.5) * p.rot_rng;
    % translations =  (rnd(2,:,:) - 0.5) * p.tnsl_range;
    
    % kspace = kspace * p.kmax / pi;
    % [new_kspace1, new_image1] = add_motion_old(reshape(kspace,[],p.Nshots,3),...
    %                                        reshape(image(:,:,:,1,:),[],p.Nshots,p.NCoils),...
    %                                        squeeze(thetas),...
    %                                        squeeze(translations));
    % rng(p.seed(2));
    % rnd = rand(2,p.Nshots,3);
    % thetas = (rnd(1,:,:) - 0.5) * p.rot_rng;
    % translations =  (rnd(2,:,:) - 0.5) * p.tnsl_range;
    % [new_kspace2, new_image2] = add_motion_old(reshape(kspace,[],p.Nshots,3),...
    %                                        reshape(image(:,:,:,2,:),[],p.Nshots,p.NCoils),...
    %                                        squeeze(thetas),...
    %                                        squeeze(translations));
    % new_kspace(:,:,:,1,:) = reshape(new_kspace1, p.NCols, [], p.Nshots,3);
    % new_kspace(:,:,:,2,:) = reshape(new_kspace2, p.NCols, [], p.Nshots,3);
    % new_image(:,:,:,1,:) = reshape(new_image1, p.NCols, [], p.Nshots, p.NCoils);
    % new_image(:,:,:,2,:) = reshape(new_image2, p.NCols, [], p.Nshots, p.NCoils);
    
%----------------------------------
    if isfield(p, 'mcf_mat')
        if isfile(p.mcf_mat)
            mats = load(p.mcf_mat);
            mats = reshape(mats, 1, 4, 4);
            mats = repmat(mats, p.Navgs*p.Nshots, 1, 1);
        elseif isfolder(p.mcf_mat)
            mats = zeros([p.Navgs*p.Nshots, 4, 4]);
            for t=0:(p.Navgs*p.Nshots-1)
                fname = sprintf('%s/MAT_%04d', p.mcf_mat, t);
                mats(t+1,:,:) = load(fname);
            end
            mats = reshape(mats, p.Navgs, p.Nshots, 4, 4);
            if isfield(p, 'no_mismatch') && p.no_mismatch
                mats(2,:,:,:) = mats(1,:,:,:);
            end
            mats = reshape(permute(mats,[2,1,3,4]),[],4,4);
        end
        
        [new_kspace, new_image] = add_motion_mat2(reshape(new_kspace, [], p.Nshots*p.Navgs, 3),...
                                                reshape(new_image, [], p.Nshots*p.Navgs, p.NCoils),...
                                                mats,...
                                                p.res,...
                                                p.recon_shape);
        new_kspace = reshape(new_kspace, p.NCols, [],  p.Nshots, p.Navgs,3);
        new_image = reshape(new_image, p.NCols, [],  p.Nshots, p.Navgs, p.NCoils);
    end
    new_kspace = new_kspace / p.kmax * pi;

    % reconstruction
    rd = reconstruct(new_kspace, new_image, p);
    
    save_avw(abs(rd), char(p.outfile), 'd', [1,1,1]*p.res);
    % if isfield(p, 'save_complex') && p.save_complex
    %     q = matfile(char([p.outfile '.mat']), 'Writable', true);
    %     q.rd = rd;
    % end

    include_path(1)
end
function [rd] = reconstruct(kspace, image, p)
    % image: NCols, Nsegs*NPhases, Nshots, Navgs, NCoils
    % kspace: NCols, Nsegs*NPhases, Nshots, Navgs, 3

    tic
    switch p.recon_type
        case 0
            % reconstruct difference image
            load(p.sens_path, 'sens');
            ktraj1 = reshape(kspace(:,:,:,1,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, 3);
            ktraj1 = reshape(permute(ktraj1,[1,2,4,3,5]), [], p.NPhases, 3);
            ktraj2 = reshape(kspace(:,:,:,2,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, 3);
            ktraj2 = reshape(permute(ktraj2,[1,2,4,3,5]), [], p.NPhases, 3);

            kd1 = reshape(image(:,:,:,1,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, p.NCoils);
            kd1 = reshape(permute(kd1,[1,2,4,3,5]),  [], p.NPhases, p.NCoils);
            kd2 = reshape(image(:,:,:,2,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, p.NCoils);
            kd2 = reshape(permute(kd2,[1,2,4,3,5]),  [], p.NPhases, p.NCoils);
            if p.optalg == "gridding"
                tmpt = 3;
                kd1 = kd1(:,1:tmpt,:);
                kd2 = kd2(:,1:tmpt,:);
                rd = zeros([p.recon_shape, tmpt, p.NCoils]);
                % rd2 = zeros([p.recon_shape, p.NPhases, p.NCoils]);
                E1 = xfm_NUFFT([p.recon_shape, tmpt], [], [], ktraj1, 'PSF', 1);
                E2 = xfm_NUFFT([p.recon_shape, tmpt], [], [], ktraj2, 'PSF', 1);
                for nc=1:p.NCoils
                    % rd1(:,:,:,:,nc) = reshape(E1'*(E1.w.*kd1(:,:,nc)), [E1.Nd, E1.Nt]);
                    % rd2(:,:,:,:,nc) = reshape(E2'*(E2.w.*kd2(:,:,nc)), [E2.Nd, E2.Nt]);
                    rd(:,:,:,:,nc) = reshape(E1'*(E1.w.*kd1(:,:,nc)), [E1.Nd, E1.Nt]) - reshape(E2'*(E2.w.*kd2(:,:,nc)), [E2.Nd, E2.Nt]);
                end
                rd = sum(rd.*conj(reshape(sens,[E1.Nd,1,size(sens,4)])), 5 ) ./ sum(sens.*conj(sens),4);
                % x2 = sum(rd2.*conj(reshape(sens,[E2.Nd,1,size(sens,4)])), 5 ) ./ sum(sens.*conj(sens),4);
                % rd = x1-x2;
                return
            end

            E1 = xfm_NUFFT([p.recon_shape, p.NPhases], sens, [], ktraj1, 'wi', 1);
            E2 = xfm_NUFFT([p.recon_shape, p.NPhases], sens, [], ktraj2, 'wi', 1);
            dd1 = E1'*kd1;
            dd2 = E2'*kd2;
            if p.optalg == "admm_mismatch"
                [x1, x2] = admm_mismatch(E1, dd1, E2, dd2, p.lambda, p.patch_size, [E1.Nd, E1.Nt], p.niter, p.rho, p.outpath);
                rd = reshape(x1-x2, [E1.Nd, E1.Nt]);
            elseif p.optalg == "admm_match"
                [rd] = admm_match(E1, dd1-dd2, p.lambda, p.patch_size, [E1.Nd, E1.Nt], p.niter, p.rho);
            elseif p.optalg == "pogm_LLR_mismatch"
                [x1, x2] = pogm_LLR_mismatch(E1, dd1, E2, dd2, p.lambda, p.patch_size, [E1.Nd, E1.Nt], p.niter);
                rd = reshape(x1-x2, [E1.Nd, E1.Nt]);
            elseif p.optalg == "pogm_LLR_split"
                [x1, x2] = pogm_LLR_split(E1, dd1, E2, dd2, p.lambda, p.patch_size, [E1.Nd, E1.Nt], p.niter);
                rd = reshape(x1-x2, [E1.Nd, E1.Nt]);
            elseif p.optalg == "pogm_LLR_match"
                [rd] = pogm_LLR_match(E1, dd1-dd2, p.lambda, p.patch_size, [E1.Nd, E1.Nt], p.niter);
            else
                error("optalg not existed")
            end
            
        case 1
            % gridding or CG-SENSE reconstruction for all repeats
            if isfield(p,'sens_path')
                load(p.sens_path, 'sens');
            else
                sens = ones(size(p.recon_shape));
            end
            if ~isfield(p,'optalg')
                p.optalg = "gridding";
            end
            kd = reshape(permute(image, [1,2,4,3,5]), [], p.Nshots*p.Navgs, p.NCoils);
            ktraj = reshape(permute(kspace, [1,2,4,3,5]), [], p.Nshots*p.Navgs, 3);
            if p.optalg == "gridding"
                E = xfm_NUFFT([p.recon_shape, p.Nshots*p.Navgs], [], [], ktraj, 'PSF',1);
                for nc=1:p.NCoils
                    rd(:,:,:,:,nc) = reshape(E'*(E.w.*kd(:,:,nc)), [E.Nd, E.Nt]); 
                end
                rd = sum(rd.*conj(reshape(sens,[E.Nd,1,size(sens,4)])), 5 ) ./ sum(sens.*conj(sens),4);
            elseif p.optalg == "CG-SENSE"
                E = xfm_NUFFT([p.recon_shape, p.Nshots*p.Navgs], sens, [], ktraj, 'wi', 1);
                dd = E' * kd;
                rd = E.iter(dd, @pcg, 1e-4, p.niter, [1, 1, 1, 0]*p.lambda);   % 1e5
                rd = reshape(rd, [E.Nd E.Nt]);
            else
                error("optalg not existed")
            end

        case 2
            % subspace reconstruct for all repeats
            if isfield(p,'sens_path')
                load(p.sens_path, 'sens');
            else
                sens = ones(size(p.recon_shape));
            end
            load(p.subspace_path, 'V')
            basis=V(:,1:p.Nk);
            % balance_basis = true;
            if isfield(p, 'balance_basis') && p.balance_basis
                basis = basis * fft(eye(p.Nk), [], 1);
            end
            % subspace t1 recon
            ktraj1 = reshape(permute(kspace(:,:,:,1,:), [1,3,2,5,4]), p.NCols, p.Nshots, p.Nsegs*p.NPhases, 3);
            ktraj2 = reshape(permute(kspace(:,:,:,2,:), [1,3,2,5,4]), p.NCols, p.Nshots, p.Nsegs*p.NPhases, 3);
            kd1 = reshape(permute(image(:,:,:,1,:), [1,3,2,5,4]),p.NCols, p.Nshots, p.Nsegs*p.NPhases, p.NCoils);
            kd2 = reshape(permute(image(:,:,:,2,:), [1,3,2,5,4]),p.NCols, p.Nshots, p.Nsegs*p.NPhases, p.NCoils);
            
            ktraj = ktraj1;
            kd = kd1;
            use_bart = true;
            if use_bart
                % use bart l1 wavelet to reconstruct
                % reshape ktraj
                disp('reconstruct using bart l1 wavelet')
                ktraj = reshape(permute(ktraj, [4,1,2,3]), [3, p.NCols, p.Nshots, 1, 1, p.Nsegs*p.NPhases]) / pi /2 .* reshape(p.recon_shape, 3, 1);
                kd = reshape(permute(kd, [1,2,4,3]), [1, p.NCols, p.Nshots, p.NCoils, 1, p.Nsegs*p.NPhases]);
                basis = reshape(basis, [1,1,1,1,1,p.Nsegs*p.NPhases,p.Nk]);
                writecfl('data/basis', basis);
                disp('bart pics')
                if p.optalg=='W'
                    [srd]=bart(['pics -e -d 5 -i 200 -R W:7:64:' num2str(p.lambda)  ' -B data/basis -t '], ktraj, kd, sens);
                elseif p.optalg=='L'
                    [srd]=bart(['pics -e -d 5 -i 200 -R L:7:7:' num2str(p.lambda)  ' -B data/basis -t '], ktraj, kd, sens);
                end
                % rd = bart('pics -RW:7:0:0.01 -i 100 -S -r 0.001', ktraj1, kd1, sens);
            else
                ktraj1 = reshape(ktraj1, p.NCols*p.Nshots, p.Nsegs*p.NPhases, 3);
                kd1 = reshape(kd1, p.NCols*p.Nshots, p.Nsegs*p.NPhases, p.NCoils);
                [bpb, dd] = precompute(ktraj1, kd1, basis, p.recon_shape, sens, floor(p.recon_shape/2));

                srd = pogm_LLR_sub(bpb, sens, dd, p.lambda, p.patch_size, [p.recon_shape, p.Nk], p.niter);
            end
            % rd = reshape( reshape(srd,[],p.Nk) * squeeze(basis)', [p.recon_shape, p.Nsegs*p.NPhases] );
            rd = squeeze(srd);
            if isfield(p, 'save_complex') && p.save_complex
                q = matfile(char([p.outfile '.mat']), 'Writable', true);
                q.basis = squeeze(basis);
                q.rd = rd;
            end
        case 3
            % subspace reconstruct for each repeat
            t = p.shot_ind(1);
            if isfield(p,'sens_path') && isfile(p.sens_path)
                load(p.sens_path, 'sens');
            elseif isfield(p,'sens_path') && isfolder(p.sens_path)
                % sens = ones(size(p.recon_shape));
                [char(p.sens_path) '/sens_' num2str(t) '_real.nii.gz']
                isfile([char(p.sens_path) '/sens_' num2str(t) '_real.nii.gz'])
                [img1,~,scales,~,~] = read_avw([char(p.sens_path) '/sens_' num2str(t) '_real.nii.gz']);
                [img2,~,scales,~,~] = read_avw([char(p.sens_path) '/sens_' num2str(t) '_imag.nii.gz']);
                sens = img1 + 1j*img2;
            end
            if p.kspace_cutoff~=1/3
                % resize sens
                for c=1:p.NCoils
                    sens_t(:,:,:,c) = imresize3(sens(:,:,:,c), p.kspace_cutoff*3);
                end
                sens = sens_t;
            end
            p.recon_shape = size(sens, 1:3);
            
            load(p.subspace_path, 'V')
            basis=V(:,1:p.Nk);
            % balance_basis = false;
            if isfield(p,'balance_basis') && p.balance_basis
                basis = basis * fft(eye(p.Nk), [], 1);
            end
                % image: NCols, Nsegs*NPhases, Nshots, Navgs, NCoils
                % kspace: NCols, Nsegs*NPhases, Nshots, Navgs, 3
            % subspace t1 recon
            kd = reshape(permute(image, [1,2,4,3,5]), p.NCols, p.Nsegs*p.NPhases, p.Nshots*p.Navgs, p.NCoils);
            ktraj = reshape(permute(kspace, [1,2,4,3,5]), p.NCols, p.Nsegs*p.NPhases, p.Nshots*p.Navgs, 3);
            
            
            rd = zeros([p.recon_shape, length(p.shot_ind)]);

            for ii = 1:length(p.shot_ind)
                use_bart = false;
                nosubspace = false;
                if ~use_bart && ~nosubspace
                    if isfield(p, 'wi')
                        wi = p.wi;  % density compensation
                    else
                        wi = 0; % no density compensation
                    end
                    [bpb, dd] = precompute(squeeze(ktraj(:,:,t,:)), squeeze(kd(:,:,t,:)), basis, p.recon_shape, sens, floor(p.recon_shape/2), wi);
                    save_avw(abs(dd), char(p.outfile), 'd', [1,1,1]*p.res);
                    % assert 1==0
                    srd = pogm_LLR_sub(bpb, sens, dd, p.lambda, p.patch_size, [p.recon_shape, p.Nk], p.niter);

                    % rd=reshape( reshape(srd,[],p.Nk) * basis', [p.recon_shape, p.Nsegs*p.NPhases] );
                    ti = ceil(0.5*p.Nsegs*p.NPhases);
                    rd(:,:,:,ii) = sum(srd .* reshape(basis(ti,:),[1,1,1,p.Nk]),4);
                    % clear srd bpb dd
                    % rd = squeeze(sum(srd .* reshape(basis',1,1,1,p.Nk,[]),4));
                elseif use_bart && ~nosubspace
                    disp('reconstruct using bart l1 wavelet')
                    ktraj_t = reshape(permute(ktraj(:,:,t,:), [4,1,2,3]), [3, p.NCols, 1, 1, 1, p.Nsegs*p.NPhases]) / pi /2 .* reshape(p.recon_shape, 3, 1);
                    kd_t = reshape(permute(kd(:,:,t,:), [1,4,2,3]), [1, p.NCols, 1, p.NCoils, 1, p.Nsegs*p.NPhases]);
                    b_t = reshape(basis, [1,1,1,1,1,p.Nsegs*p.NPhases,p.Nk]);
                    fname=tempname;
                    writecfl(fname, b_t);
                    disp('bart pics')
                    [srd]=bart(['pics -e -d 5 -i 100 -R L:7:7:' num2str(p.lambda) '-B ' fname ' -t '], ktraj_t, kd_t, sens);
                    % [srd]=bart(['pics -e -d 5 -i 100 -R W:7:64:0.0001 -B ' fname ' -t '], ktraj_t, kd_t, sens);
                    % rd = reshape( reshape(srd,[],p.Nk) * squeeze(b_t)', [p.recon_shape, p.Nsegs*p.NPhases] );
                    ti = ceil(0.5*p.Nsegs*p.NPhases); % match the TI of mprage 904 ms
                    rd(:,:,:,ii) = sum(reshape(srd,[p.recon_shape, p.Nk]) .* reshape(basis(ti,:),[1,1,1,p.Nk]),4);
                    delete([fname '.hdr']);
                    delete([fname '.cfl']);
                else
                    ktraj_t = reshape(permute(ktraj(:,:,t,:), [4,1,2,3]), [3, p.NCols, p.Nsegs*p.NPhases]) / pi /2 .* reshape(p.recon_shape, 3, 1);
                    kd_t = reshape(kd(:,:,t,:), [1, p.NCols, p.Nsegs*p.NPhases, p.NCoils]);
                    [rd] = bart(['pics -e -d 5 -i 50 -R W:7:0:0.0001 -t '], ktraj_t, kd_t, sens);
                end
            end
            % rd = reshape(rd, [p.recon_shape, p.Nshots*p.Navgs]);
        
        case 4
            % segment each repeat and reconstruct for higher temporal resolution motion status
            if isfield(p,'sens_path')
                load(p.sens_path, 'sens');
            else
                sens = ones(size(p.recon_shape));
            end
            load(p.subspace_path, 'V');
            basis=V(:,1:p.Nk);
            kd = reshape(permute(image, [1,2,4,3,5]), p.NCols, p.Nsegs*p.NPhases, p.Nshots*p.Navgs, p.NCoils);
            ktraj = reshape(permute(kspace, [1,2,4,3,5]), p.NCols, p.Nsegs*p.NPhases, p.Nshots*p.Navgs, 3);
            
            Nt = size(V,1);
            Nt_sub = Nt/6;
            rd = zeros([p.recon_shape, 4, p.Nshots*p.Navgs, p.Nk]);

            for ii = 1:6
                for t = p.shot_ind
                    t0 = (ii-1)*Nt_sub+1;
                    t1 = ii*Nt_sub;
                    [bpb, dd] = precompute(squeeze(ktraj(:,t0:t1,t,:)), squeeze(kd(:,t0:t1,t,:)), basis(t0:t1,:), p.recon_shape, sens, floor(p.recon_shape/2));

                    srd = pogm_LLR_sub(bpb, sens, dd, p.lambda, p.patch_size, [p.recon_shape, p.Nk], p.niter);

                    % rd=reshape( reshape(srd,[],p.Nk) * basis', [p.recon_shape, p.Nsegs*p.NPhases] );
                    rd(:,:,:,ii,t,:) = srd;
                end
            end
            rd = reshape(rd, [p.recon_shape, 6*p.Nshots*p.Navgs*p.Nk]);
        
        case 5
            % estimate sensitivity maps using bart NLINV
            % image: NCols, Nsegs*NPhases, Nshots, Navgs, NCoils
            % kspace: NCols, Nsegs*NPhases, Nshots, Navgs, 3

            % reshape data for bart nlinv reconstruction
            ktraj1 = reshape(kspace(:,:,:,1,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, 3);
            ktraj = reshape(ktraj1(:,:,end-1:end,:,:), p.NCols, p.Nsegs*2*p.Nshots, 3);
            ktraj = permute(ktraj, [3,1,2]) / pi /2 .* reshape(p.recon_shape, 3, 1);
            kd1 = reshape(image(:,:,:,1,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, p.NCoils);
            kd = reshape(kd1(:,:,end-1:end,:,:), 1, p.NCols, p.Nsegs*2*p.Nshots, p.NCoils);

            % estimate sensitivity maps
            [rd, sens] = bart('nlinv -m1 -i100 -d5 -t', ktraj, kd);
            
        
        case 6
            % reconstruct with different sensitivity maps for each shot
            % image: NCols, Nsegs*NPhases, Nshots, Navgs, NCoils
            % kspace: NCols, Nsegs*NPhases, Nshots, Navgs, 3
            senses = zeros([p.recon_shape, p.Nshots, p.NCoils]);
            if isfield(p,'sens_path')
                if isfolder(p.sens_path)
                    for i =1:p.Nshots
                        load([char(p.sens_path), '/sens_', num2str(2*i-1), '.mat'], 'sens');
                        senses1(:,:,:,i,:) = sens;
                        load([char(p.sens_path), '/sens_', num2str(2*i), '.mat'], 'sens');
                        senses2(:,:,:,i,:) = sens;
                    end
                else
                    error("sens_path not a folder")
                end
            else
                error("sens_path not existed")
            end
            ktraj1 = reshape(kspace(:,:,:,1,:), p.NCols* p.Nsegs, p.NPhases*p.Nshots, 3);
            ktraj2 = reshape(kspace(:,:,:,2,:), p.NCols* p.Nsegs, p.NPhases*p.Nshots, 3);

            kd1 = reshape(image(:,:,:,1,:), p.NCols*p.Nsegs, p.NPhases, p.Nshots, p.NCoils);
            kd2 = reshape(image(:,:,:,2,:), p.NCols*p.Nsegs, p.NPhases, p.Nshots, p.NCoils);

            E1 = xfm_NUFFT([p.recon_shape, p.NPhases*p.Nshots], [], [], ktraj1, 'wi', 1, 'PSF', 1);
            E2 = xfm_NUFFT([p.recon_shape, p.NPhases*p.Nshots], [], [], ktraj2, 'wi', 1,  'PSF', 1);
            dd1 = mtimes_adj_sens(E1, kd1, senses1);
            dd2 = mtimes_adj_sens(E2, kd2, senses2);

            [x1, x2] = admm_mismatch_sens(E1, dd1, E2, dd2, senses1, senses2, p.lambda, p.patch_size, [E1.Nd, p.NPhases], p.niter, p.rho, p.outpath);
            rd = reshape(x1-x2, [E1.Nd, p.NPhases]);
        
        case 7
            % reconstruct image with sampling from each shot
            if isfield(p,'sens_path')
                load(p.sens_path, 'sens');
            end
            [gt_img,~,scales,~,~] = read_avw(p.refimg_path);
            ktraj = reshape(permute(kspace, [1,2,4,3,5]), p.NCols, p.Nsegs*p.NPhases, p.Nshots*p.Navgs, 3);
            t = p.shot_ind(1);
            ktraj_t = reshape(ktraj(:,:,t,:), p.NCols*p.Nsegs*p.NPhases,1,3);
            size(ktraj_t)
            p.recon_shape
            E = xfm_NUFFT([p.recon_shape,1], sens, [], ktraj_t, 'wi', 1, 'PSF', 1);
            kd = reshape(E*gt_img, 1, p.NCols, p.Nsegs*p.NPhases,p.NCoils);  % kd: [p.NCols*p.Nsegs*p.NPhases, 1, p.NCoils]

            ktraj_t = reshape(squeeze(ktraj_t)', [3, p.NCols, p.Nsegs*p.NPhases]) /pi /2 .* reshape(p.recon_shape, 3, 1);
            [rd] = bart(['pics -e -d 5 -i 200 -R ' p.optalg ':7:0:' num2str(p.lambda) ' -t '], ktraj_t, kd, sens);

        case 8
            % reconstruct anat image for coil sensitivity estimation
            % image: NCols, Nsegs*NPhases, Nshots, Navgs, NCoils
            % kspace: NCols, Nsegs*NPhases, Nshots, Navgs, 3
            kd = reshape(image, p.NCols, p.Nsegs, p.NPhases, p.Nshots, p.Navgs, p.NCoils);
            kd = reshape(kd(:,:,end-1:end,:,1,:)+kd(:,:,end-1:end,:,2,:), [], p.NCoils);
            ktraj = reshape(kspace, p.NCols, p.Nsegs, p.NPhases, p.Nshots, p.Navgs, 3);
            ktraj = reshape(ktraj(:,:,end-1:end,:,1,:), [], 1, 3);


            t0 = tic;
            E = xfm_NUFFT([p.recon_shape, 1], [], [], ktraj, 'PSF', 1);
            dt = toc(t0); disp("xfm_NUFFT took " + num2str(dt/60) + "min");
            recon_anat = zeros([p.recon_shape, p.NCoils]);
            for ii = 1:p.NCoils
                tic
                recon_anat(:,:,:,ii) = squeeze(reshape(E' * (E.w .* kd(:,ii) ), p.recon_shape));
                % recon_anat(:,:,:,:,ii) = reshape( E.iter( kd(:,ii),@pcg,1E-4,50,[1E3,1E3,1E3,0] ), recon_shape);
                % if isangio
                %     L = 0.3;
                % else
                %     L = 1;
                % end
                % recon_anat(:,:,:,ii) = squeeze(blurred_adj(E.w.^2.*kd(:,ii), E.st(1), L));
                t = toc; disp("recon coil " + num2str(ii) + " took " + num2str(t/60) + "min");
            end
            rd = squeeze(sum(abs(recon_anat).^2, 4).^0.5);
            q = matfile([char(p.outfile) '.mat'], 'Writable', true);
            q.m = squeeze(recon_anat);
            q.anat = rd;
        case 9
            senses1 = zeros([p.recon_shape(1), p.recon_shape(2), p.recon_shape(3), p.NCoils, p.Nshots]);
            senses2 = zeros([p.recon_shape(1), p.recon_shape(2), p.recon_shape(3), p.NCoils, p.Nshots]);
            for ii=1:p.Nshots
                load([char(p.sens_path), '/sens_', num2str(2*ii-1), '.mat'], 'sens');
                senses1(:,:,:,:,ii) = sens;
                load([char(p.sens_path), '/sens_', num2str(2*ii), '.mat'], 'sens');
                senses2(:,:,:,:,ii) = sens;
            end
            [img,~,scales,~,~] = read_avw('/vols/Data/okell/qijia/perf_recon_1-12-23/scan_1/mpr_sens_mask.nii.gz')
            mask = img;
            senses1 = senses1 .* mask;
            senses2 = senses2 .* mask;

            ktraj1 = reshape(kspace(:,:,:,1,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, 3);
            ktraj2 = reshape(kspace(:,:,:,2,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, 3);

            kd1 = reshape(image(:,:,:,1,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, p.NCoils);
            kd2 = reshape(image(:,:,:,2,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, p.NCoils);
            
            % kt = reshape(permute(ktraj1,[1,2,4,3,5]), [], p.NPhases, 3);
            % E = xfm_NUFFT([p.recon_shape(1),p.recon_shape(2),p.recon_shape(3), p.NPhases], senses1(:,:,:,:,1), [], kt, 'wi', 1);
            
            Es1 = precal_E_sens(ktraj1, senses1);
            Es2 = precal_E_sens(ktraj2, senses2);

            dd1 = mtimes_adj_sens(Es1, kd1);
            dd2 = mtimes_adj_sens(Es2, kd2);

            % ktraj1 = reshape(kspace(:,:,:,1,:), p.NCols, p.Nsegs, p.NPhases, p.Nshots, 3);
            % kt = reshape(permute(ktraj1,[1,2,4,3,5]), [], p.NPhases, 3);
            % E = xfm_NUFFT([p.recon_shape(1),p.recon_shape(2),p.recon_shape(3), p.NPhases], senses1(:,:,:,:,1), [], kt, 'wi', 1);
            % L = 1/E.max_step(10);
            
            if p.optalg == 'pogm_LLR_split'
                [x1, x2] = pogm_LLR_split_sens(Es1, dd1, Es2, dd2, p.lambda, p.patch_size, [p.recon_shape, p.NPhases], p.niter);
            else
                [x1, x2] = pogm_LLR_mismatch_sens(Es1, dd1, Es2, dd2, p.lambda, p.patch_size, [p.recon_shape, p.NPhases], p.niter);
            end
            rd = reshape(x1-x2, [p.recon_shape, p.NPhases]);
        otherwise
            error("recon_type not existed")
    end
    t = toc; disp(['recon took ' char(num2str(t/60/60)) ' hours']);
end
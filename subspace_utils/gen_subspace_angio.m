function gen_subspace()
    addpath("/home/fs0/qijia/code/subspace/CAPRIAModel")
    addpath("/home/fs0/qijia/code/SimTraj/MChiewCAPRIARecon")
    % simulation
    Nsegs = 3;
    Nphases = 48;

    Aparams = [];
    Aparams.A = 1;
    Aparams.delta_t_min = 0; 

    load('sample_dist/todata','dt','p','s');
    Aparams.delta_ts = dt;
    Aparams.ss = s;
    Aparams.ps = p;

    % load('sample_dist/todata','dt','p','s');
    % Aparams.delta_ts = [Aparams.delta_ts; dt];
    % Aparams.ss = [Aparams.ss; s];
    % Aparams.ps = [Aparams.ps; p];

%     load('sample_dist/to_params','dt','p','s');
%     Aparams.delta_ts = [Aparams.delta_ts; dt];
%     Aparams.ss = [Aparams.ss; s];
%     Aparams.ps = [Aparams.ps; p];


    [dM] = capria_sim(Nsegs, Nphases, Aparams);

%     dM = dM(1:100,:);

    Nt = size(dM, 1);
    % Ns = prod(size(dM, 2:4));
    Ns = size(dM, 2);
    dM = reshape(dM, Nt, Ns);

    [~, S, V] = svd(dM', 'econ');
    disp(diag(S))
    assert(size(V,1) == Nt)

    for Nk = [4, 8, 12, 20]
        B = V(:, 1:Nk);   % Nt x Nk
        err = sum( (dM - B*B'*dM).^2 , 'all') / sum(dM(:).^2) * 100;
        disp("Nk = " + num2str(Nk) + " error = " + num2str(err));
    end
    save(char("basis_todata_"+num2str(Nphases)+"frames"),'V');
    % save('/home/fs0/qijia/scratch/subspace/V','dM');
end

function [dM] = capria_sim(Nsegs, Nphases, Aparams)
    % Sequence parameters
    tau = 1.8; 
    TR = 14.7e-3;
    t0 = tau+2e-3+10e-3+11e-3+10e-3+2e-3;
    t = t0+((1:Nphases)-0.5)*TR*Nsegs;
%     t = t0:TR:(t0+(Nsegs*Nphases-1)*TR);

    VFAMin = 3; 
    VFAMax = 12; 
    VFAParams = [VFAMin VFAMax];

    % Physio parameters
    % Aparams = [];
    % Aparams.A = 1;
    % num = 60;
    % Aparams.delta_ts = linspace(0.1,2.2,num);
    % Aparams.ss = linspace(0.1,12,num);
    % Aparams.ps = linspace(4,15,num)*1e-3;
    % Aparams.delta_t_min = 0; 
    % Aparams = [];
    % Aparams.A = 1; Aparams.delta_ts = 0.2:0.1:1; 
    % Aparams.ss = 1:20; Aparams.ps = [1 10 100:200:900]*1e-3; 
    % Aparams.delta_t_min = 0; 

    % T1 of blood
    T1b = get_relaxation_times(3,'blood')/1000; 

    clear dM VFA_Alpha tAv dMAv
    max_delta_t = 0;
    for ii = 1:length(Aparams.ss)
        Aparams.s = Aparams.ss(ii);
        Aparams.p = Aparams.ps(ii);
        Aparams.delta_t = Aparams.delta_ts(ii);
        if Aparams.delta_t > max_delta_t
            max_delta_t = Aparams.delta_t;
        end
        [dM(:,ii), VFA_Alpha, ~, ~, tAv, dMAv(:,ii)] = CAPRIASignal('Angio','Quadratic',VFAParams,t,t0,tau,T1b,TR,Aparams,false,true,Nsegs,Nphases,false);
%         dM(:,ii) = dM(:,ii) * exp(1*Aparams.delta_t);
    end
    disp("max_delta_t "+ num2str(max_delta_t));
    % for ii = 1:length(Aparams.ss)
    %     disp(ii);
    %     Aparams.s = Aparams.ss(ii);
    %     for jj = 1:length(Aparams.ps)
    %         Aparams.p = Aparams.ps(jj);
            
            
    %         % Angio
    %         for kk = 1:length(Aparams.delta_ts)
    %             Aparams.delta_t = Aparams.delta_ts(kk);
    %             [dM(:,ii,jj,kk), VFA_Alpha, ~, ~, tAv, dMAv(:,ii,jj,kk)] = CAPRIASignal('Angio','Quadratic',VFAParams,t,t0,tau,T1b,TR,Aparams,false,true,Nsegs,Nphases,false);
    %         end
    %     end
    % end

    % Plot to check
    % figure;
    % cols = distinguishable_colors(length(Aparams.delta_ts),[1 1 1]);
    % ii = 2; jj = 2;
    % for kk = 1:length(Aparams.delta_ts)
    %     plot(t,squeeze(dM(:,ii,jj,kk)),'color',cols(kk,:)); hold on;
    %     plot(tAv,squeeze(dMAv(:,ii,jj,kk)),'o','color',cols(kk,:))
    % end
    % saveas(gcf, fullfile(outdir, 'sim.png'));

    % q = matfile(fullfile(outdir, 'sim.mat'));
    % q.Properties.Writable = true;
    % q.dM = dM;
    % q.dMAv = dMAv;

    % % Save out
    % save_avw(permute(dMAv,[2 3 4 1]),fullfile(outdir, 'Test_CAPRIA_Angio_Data'),'f',[1 1 1 1])
    % save_avw(ones(size(permute(dMAv(1,:,:,:),[2 3 4 1]))),fullfile(outdir, 'Test_CAPRIA_Angio_Data_Mask'),'b',[1 1 1 1])
end
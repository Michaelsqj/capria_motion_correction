function gen_subspace_perf()
    addpath("/home/fs0/qijia/code/subspace/CAPRIAModel")
    addpath("/home/fs0/qijia/code/SimTraj/MChiewCAPRIARecon")
    % simulation
    Nsegs = 36;
    Nphases = 6;
    
    [dM] = capria_sim(Nsegs, Nphases);

    Nt = size(dM, 1);
    Ns = size(dM, 2);
    dM = reshape(dM, Nt, Ns);

    [~, S, V] = svd(dM', 'econ');
    disp(diag(S))
    assert(size(V,1) == Nt)

    for Nk = [2,3,4,6]
        B = V(:, 1:Nk);   % Nt x Nk
        err = sum( (dM - B*B'*dM).^2 , 'all') / sum(dM(:).^2) * 100;
        disp("Nk = " + num2str(Nk) + " error = " + num2str(err));
    end
    save('subspace_mat/subspace_perf_216.mat','V', 'dM');
end

function [dMAv] = capria_sim(Nsegs, Nphases)
    % Sequence parameters
    tau = 1.8; 
    TR = 9.8*1e-3;
    t0 = tau+2e-3+10e-3+11e-3+10e-3+2e-3;
    t = t0:TR:(t0+(Nsegs*Nphases-1)*TR);

    VFAMin = 2; 
    VFAMax = 9; 
    VFAParams = [VFAMin VFAMax];
    FAMode = 'Quadratic';

    % T1 of blood
    T1b = get_relaxation_times(3,'blood')/1000; 

    max_delta_t = 0;
    params.delta_t_min = 0;
    params.f = 1;
    params.s = 15;
    params.p = 2e-3;
    T1gm = 1330*1e-3;
    T1wm = 830*1e-3;
    % 750 - 1400 ms
    params.T1 = T1gm;
    delta_ts = linspace(0.5, 2.5, 100);
    % Calculate flip angle scheme
    for ii = 1:length(delta_ts)

        params.Deltat = delta_ts(ii);
        [dM(:,ii), VFA_Alpha, ~, ~, tAv, dMAv(:,ii)] = CAPRIASignal('perf',FAMode,VFAParams,t,t0,tau,T1b,TR,params,false,true,Nsegs,Nphases,false);
    end
    rmpath("/home/fs0/qijia/code/subspace/CAPRIAModel")
    rmpath("/home/fs0/qijia/code/SimTraj/MChiewCAPRIARecon")
end
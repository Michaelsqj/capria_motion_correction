function [dMs] = simulate_angio(As, delta_ts, ps, ss, Nt, prottype, tau)
    if nargin < 7
        tau = 0.001;
    end
    % dMs: Nt x Nsample
    switch prottype
        case 1
        % to_radial_matched_TR, cone
            TR = 14.7e-3;  Nsegs=12; Nphases = 12; 
            VFAMin = 3;     VFAMax = 12;    VFAParams = [VFAMin VFAMax];
            outname='cone_radial_matched_TR_144'
        case 2
            % to_radial_prev_prot
            TR = 10.6e-3;  Nsegs=18; Nphases = 12; 
            VFAMin = 2;     VFAMax = 9;    VFAParams = [VFAMin VFAMax];
            outname='cone_radial_prev_prot_216'
        case 3
            % water excitation cone
            TR = 16e-3;  Nsegs=12; Nphases = 12; 
            VFAMin = 3;     VFAMax = 12;    VFAParams = [VFAMin VFAMax];
            outname='cone_water_excitation_144'
        case 4
            % high resolution 
            TR = 15.5e-3;  Nsegs=12; Nphases = 12; 
            VFAMin = 3;     VFAMax = 12;    VFAParams = [VFAMin VFAMax];
            outname='cone_high_res_144'
    end

    % tau = 0.001; 
%     tau = 1e-4;
    t0 = tau+2e-3+10e-3+11e-3+10e-3+2e-3;  % double check with the sequence
    t = t0:TR:(t0+(Nsegs*Nphases-1)*TR);
    T1b = get_relaxation_times(3,'blood')/1000;     % T1 of blood at 3T


    %% simulate signal
    Nsegs=Nphases*Nsegs/Nt
    Nphases=Nt;
    dMs = zeros(Nphases*Nsegs, length(delta_ts));
    dMAvs = zeros(Nphases, length(delta_ts));
    for ii = 1:length(delta_ts)
        params.p = ps(ii);
        params.s = ss(ii);
        params.delta_t = delta_ts(ii);
        params.A = As(ii);
        params.delta_t_min = 0; 
        % Sig = DynAngioTheoreticalIntGammaDeltaTMin(t,tau,T1b,0,[],TR,params.A,params.delta_t,params.s,params.p,params.delta_t_min) / params.A * 2;
        Sig = DynAngioTheoreticalIntGammaNoRFOrT1(t,tau,params.A,params.delta_t,params.s,params.p);
        dMs(:,ii) = Sig;
        % dMAvs(:,ii) = dMAv(:);
    end
end
function [kspace, p] = create_kspace(p)
    % ---------------------
    %  return k-space trajectory, range [-kmax, kmax]
    %   shape [NCols, NLines, ndim]
    %   
    %   
    %----------------------
    
    ninterleaves = p.NLines * p.Nt;
    %% create base_k
    % generate base_g, base_k
    [~,base_g,~] = gen_base_cone(p);
    base_k = convert_g2k(base_g);
    % interpolation
    base_k = calc_ADCpts(base_k, p.T, p.Ts, p.NCols);  % NCols x 3
    
    %% create rotation matrix
    seed = 32767.0;
    Theta = gen_rand(ninterleaves) / seed * 2.0 * pi;
    GRCounter = reshape(1:ninterleaves, [], 1);
    [Azi, Polar] = GoldenMeans3D(GRCounter,p.GRtype);
    GrPRS = [sin(Azi).*sin(Polar), cos(Azi).*sin(Polar), cos(Polar)];
    [GrPRS, GsPRS, GrRad, GsRad, R] = calc_slice(GrPRS, Theta);      % R [ninterleaves, 3, 3]
    
    %% rotate 
    kspace = zeros(p.NCols, ninterleaves, 3);
    for ii = 1: ninterleaves
        kspace(:, ii, :) = (squeeze(R(ii,:,:)) * base_k')';
    end

    %% kspace cutoff
    if isfield(p, 'kspace_cutoff') && p.kspace_cutoff<1
        kr = sum(base_k.^2, 2).^0.5;
        p.kmax = p.kmax * p.kspace_cutoff;
        perf_pts = find(kr<p.kmax);
        p.NCols = length(perf_pts);
        kspace = kspace(perf_pts, :,:);
        p.res = p.res / p.kspace_cutoff;
    end
    
end
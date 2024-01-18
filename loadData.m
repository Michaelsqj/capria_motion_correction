function [kdata, ktraj, p, image, kspace, base_k] = loadData(ind, fpath, p)
    codepath = pwd;

    %% load k-space data from Siemens .dat file
    cd(fpath);

    matchfile;  % load files matching gradient and measID, etc.

    gradname = char(gradnames(ind))
    measID = measIDs(ind)
    if isstring(measID)
        measID = char(measID)
    end
    dead_ADC_pts = dead_ADC_ptss(ind)
    if exist('oldshifts','var')
        oldshift = oldshifts(ind)
    else
        oldshift = false;
    end
    if exist('GRtypes','var')
        GRtype = GRtypes(ind)   % full sphere golden ratio rotation
    else
        GRtype = 1  % bit-reversed half sphere rotation
    end
    if exist('useThetas','var')
        useTheta = useThetas(ind)
    else
        useTheta = 1
    end

    twix_obj = mapVBVD(measID,'ignoreSeg',true,'removeOS',false);
    cd(codepath);

    if numel(twix_obj) > 1
        twix_obj = twix_obj{end};
    end
    dataSize = twix_obj.image.dataSize;

    image=twix_obj.image(:,:,:,:,:,:,:,:,:,:,:,:,:,:,:,:);
    image = squeeze(image);
    [NCols, NCoils, NLines, Navgs, NPhases] = size(image);
    Nsegs = twix_obj.hdr.Config.NSeg;
    Nshots = NLines / Nsegs;
    KMtxSize = NCols;

    %% load randnum
    % randnum = load(fpath + "ktraj/randnum");
    % randnum = randnum(1:Nsegs*NPhases*Nshots);
    % Theta   = randnum / 32767.0 *2.0*pi;
    if useTheta
        randnum = twix_obj.image.iceParam(7,:);
        randnum = reshape(randnum, Nsegs, NPhases, Navgs, Nshots);
        randnum = reshape(randnum(:,:,1,:), [], 1);
        Theta = randnum / 32767.0 *2.0*pi;
    else
        Theta = zeros(Nsegs*NPhases*Nshots, 1);
    end

    %% set basic parameters
    slicePos = [0,0,0];
    if isfield(twix_obj.hdr.MeasYaps.sSliceArray.asSlice{1, 1}, 'sPosition')
        if isfield(twix_obj.hdr.MeasYaps.sSliceArray.asSlice{1, 1}.sPosition, 'dSag')
        slicePos(1) = twix_obj.hdr.MeasYaps.sSliceArray.asSlice{1, 1}.sPosition.dSag; % mm
        end
        if isfield(twix_obj.hdr.MeasYaps.sSliceArray.asSlice{1, 1}.sPosition, 'dCor')
        slicePos(2) = twix_obj.hdr.MeasYaps.sSliceArray.asSlice{1, 1}.sPosition.dCor; % mm
        end
        if isfield(twix_obj.hdr.MeasYaps.sSliceArray.asSlice{1, 1}.sPosition, 'dTra')
        slicePos(3) = twix_obj.hdr.MeasYaps.sSliceArray.asSlice{1, 1}.sPosition.dTra; % mm
        end
    end
    % slicePos = slicePos/10; % cm
    sliceThickness = twix_obj.hdr.MeasYaps.sSliceArray.asSlice{1, 1}.dThickness;    % mm

    OS = twix_obj.hdr.Dicom.flReadoutOSFactor;
    mat = twix_obj.hdr.Config.BaseResolution;
    fov = twix_obj.hdr.Config.RoFOV;
    res = fov/mat;
    kmax = 5/res;

    Ts = twix_obj.hdr.MeasYaps.sRXSPEC.alDwellTime{1} * 1e-6;
    LEN             = mat * OS;
    readout_time    = LEN * Ts;                           % ms
    T = 10e-3;
    grad_time       = ceil(readout_time / T) * T;
    grad_pts = round(grad_time/T);

    %% generate k-traj

    % rotate base_k
    GRCounter = twix_obj.image.iceParam(5,:);
    GRCounter = reshape(GRCounter, Nsegs, NPhases, Navgs, Nshots);
    GRCounter = reshape(GRCounter(:,:,1,:), [], 1);
    [Azi, Polar] = GoldenMeans3D(GRCounter,GRtype);
    GrPRS = [sin(Azi).*sin(Polar), cos(Azi).*sin(Polar), cos(Polar)];
    [GrPRS, GsPRS, GrRad, GsRad, R] = calc_slice(GrPRS, Theta);      % R [Nsegs*NPhases*Nshots, 3, 3]

    % load gradient
    if contains(gradname, "radial")
        base_k = zeros(grad_pts,3);
        base_k(:,3) = linspace(-kmax,kmax, grad_pts);

        base_k = [base_k(:,2), base_k(:,3), base_k(:,1)];   % Phase-Read-Slice coordinate system
        % interpolation
        base_k = calc_ADCpts(base_k, T, Ts, NCols);  % NCols x 3
        
        kspace = zeros(NCols, Nsegs*NPhases*Nshots, 3);
        for ii = 1: (Nsegs*NPhases*Nshots)
            kspace(:, ii, :) = (squeeze(R(ii,:,:)) * base_k')';
        end
    elseif contains(gradname, "sparkling")
        kspace = load_sparkling(fpath, NCols, Nsegs, NPhases, Nshots, R, dead_ADC_pts, Ts, T);
        base_k = squeeze(kspace(:,1,:));
    else
        base_g = load(fpath + "ktraj/" + gradname);
        deadpts = ceil(dead_ADC_pts * Ts / 10e-3)

        base_g = [zeros(deadpts,3); base_g];
        % end
        base_k(:,1) = cumtrapz(squeeze(base_g(:,1))) .* 4.258 .* T;
        base_k(:,2) = cumtrapz(squeeze(base_g(:,2))) .* 4.258 .* T;
        base_k(:,3) = cumtrapz(squeeze(base_g(:,3))) .* 4.258 .* T;

        base_k = [base_k(:,2), base_k(:,3), base_k(:,1)];   % Phase-Read-Slice coordinate system
        % interpolation
        base_k = calc_ADCpts(base_k, T, Ts, NCols);  % NCols x 3

        kspace = zeros(NCols, Nsegs*NPhases*Nshots, 3);
        for ii = 1: (Nsegs*NPhases*Nshots)
            kspace(:, ii, :) = (squeeze(R(ii,:,:)) * base_k')';
        end
    end

    kspace = reshape(kspace, NCols, Nsegs, NPhases, Nshots, 3);
    kspace = kspace./kmax.*pi;

    %% discard dead ADC pts
    NCols = NCols - dead_ADC_pts;
    kspace = kspace(dead_ADC_pts+1:end, :, :, :, :);
    image = image(dead_ADC_pts+1:end, :, :, :, :);

    %% coil compression
    % Calculate the transformation to compress the coils
    % NCols, NCoils, NLines, Navgs, NPhases
    if p.compress
        if isfield(p, 'xfm')
            load(p.xfm, 'xfm', 'Nc');
            % Nc = 8;
            tmp = permute(image, [1,3,4,5,2]);
            image = apply_sens_xfm(xfm, reshape(tmp, [], NPhases, NCoils), Nc, 3);
            NCoils = Nc;
            image = permute(reshape(image, NCols, NLines, Navgs, NPhases, NCoils), [1,5,2,3,4]);
            size(image)
        else
            tmp = permute(image, [1,3,4,5,2]);
            [~, xfm, ~] = calc_psens(reshape(tmp,[],NCoils));
            Nc = 8;
            image = apply_sens_xfm(xfm, reshape(tmp, [], NPhases, NCoils), Nc, 3);
            NCoils = Nc;
            image = permute(reshape(image, NCols, NLines, Navgs, NPhases, NCoils), [1,5,2,3,4]);
            size(image)
        end
    end

    %% kspace cutoff for lower resolution
    if isfield(p, 'kspace_cutoff') && p.kspace_cutoff<1
        kr = sum(base_k.^2, 2).^0.5;
        kmax = kmax * p.kspace_cutoff;
        perf_pts = find(kr<kmax);
        NCols = length(perf_pts);
        kspace = kspace(perf_pts, :,:,:,:)./p.kspace_cutoff;
        image  = image(perf_pts, :,:,:,:);
        res = res / p.kspace_cutoff;
    end



    %% reshape kspace, image, no NPhases needed
    %% image: NCols, NCoils, NLines, Navgs, NPhases
    %% kspace: NCols, Nsegs, NPhases, Nshots, 3
    image = reshape(image, NCols, NCoils, Nsegs, Nshots, Navgs, NPhases);
    image = permute(image, [1,3,6,4,5,2]);
    image = reshape(image, NCols, Nsegs*NPhases, Nshots, Navgs, NCoils);
    
    kspace = reshape(kspace, NCols, Nsegs*NPhases, Nshots, 3);

    %% add phase to image, 2*pi* (k*r)
    % if ~oldshift && ~contains(gradname, "radial")

    if (~oldshift && ~contains(gradname, "radial")) || isfield(p, 'addshift')
        image = exp(1j.*2*pi*sum(kspace./pi.*0.1*kmax.*reshape(slicePos, 1,1,1,3),4)) .* image;
    end
    
    %% add additional shift to center the image
    % the sign will be inverted, for example if want to shift right 3mm, then use 3, but a negative sign is added below
    if exist('additional_shift','var') && ~isempty(additional_shift)
        image = exp(1j.*2*pi*sum(kspace./pi.*0.1*kmax.*reshape(-additional_shift, 1,1,1,3),4)) .* image;
    end
    
    %% construct kdata, ktraj to reconstruct angiography / perfusion
    %% ktraj: NCols*NLines, NPhases, 3
    %% kdata: NCols*NLines, NPhases, Navgs, NCoils
    ii = 1;
    while ii*Nsegs <= size(image, 2)
        ktraj(:, ii, :) = reshape(kspace(:, (ii-1)*Nsegs+1:ii*Nsegs, :, :), [], 1, 3);
        kdata(:, ii, :, :) = reshape(image(:, (ii-1)*Nsegs+1:ii*Nsegs, :, :, :), [], 1, Navgs, NCoils);
        ii = ii+1;
    end
    NPhases = ii-1

    if isfield(p, 'Nt')
        disp("use custom Nt")
        Nsegs = NPhases*Nsegs/p.Nt
        NPhases = p.Nt
    end

    p.measID    = measID;
    p.NCols     = NCols;
    p.NCoils    = NCoils;
    p.Nsegs     = Nsegs;
    p.NPhases   = NPhases;
    p.Nshots    = Nshots;
    p.Navgs     = Navgs;
    p.mat       = mat;
    p.fov       = fov;
    p.res       = res;
    p.kmax      = kmax;
    p.res       = res;
    p.gradname  = gradname;
    p.recon_angi_shape = recon_angi_shape;
    p.recon_perf_shape = recon_perf_shape;
    p.angi_shift= angi_shift;
    p.perf_shift= perf_shift;
end

% test reconstruction on close to fully sampled data, compare betwen ADMM and POGM
function test_recon(optalg, lambda, patch_size, niter, rho)
    if nargin < 5
        rho = 1;
    end
    disp(optalg)
    disp(optalg=="pogm_LLR_match")
    include_path();
    % 1. load a 6 frames clean image
    fname = '/home/fs0/qijia/scratch/moco_exp/expout/invivo_19_9_23_1/pogm_LLR_match.nii.gz'
    [img,~,scales,~,~]=read_avw(fname);
    im_size = size(img);
    % 2. create sampling trajectory using radial
    NCols = 2*max(im_size);
    base_k = zeros(NCols, 3);
    base_k(:,2) = linspace(-pi, pi, NCols);

    Nsegs = 48;
    Nshots = 48;
    NPhases = im_size(4);

    GRCounter = 1:Nsegs*NPhases*Nshots;
    [Azi, Polar] = GoldenMeans3D(GRCounter,1);
    GrPRS = [sin(Azi).*sin(Polar), cos(Azi).*sin(Polar), cos(Polar)];
    Theta = zeros(Nsegs*NPhases*Nshots, 1);
    [GrPRS, GsPRS, GrRad, GsRad, R] = calc_slice(GrPRS, Theta);      % R [Nsegs*NPhases*Nshots, 3, 3]

    kspace = zeros(NCols, Nsegs*NPhases*Nshots, 3);
    for ii = 1: (Nsegs*NPhases*Nshots)
        kspace(:, ii, :) = (squeeze(R(ii,:,:)) * base_k')';
    end

    ktraj = reshape(kspace, [NCols*Nsegs*Nshots, NPhases, 3]);

    % 3. load sensitivity maps
    load('/vols/Data/okell/qijia/perf_recon_5-5-23/meas_MID00111_FID13940_to_CV_VEPCASL_v0p6_qijia_36x49_176_164Hz_vFA_sens1.mat','sens');
    size(sens)

    % 4. create NUFFT operatore
    E = xfm_NUFFT(im_size, sens, [], ktraj, 'wi', 1, 'table', true);
    dd = E.mtimes2(img);

    % 5. reconstruct
    if optalg == "admm_match"
        [rd] = admm_match(E, dd, lambda, [1 1 1]*patch_size, [E.Nd, E.Nt], niter, rho);
    elseif optalg == "pogm_LLR_match"
        [rd] = pogm_LLR_match(E, dd, lambda, [1 1 1]*patch_size, [E.Nd, E.Nt], niter);
    elseif optalg == "fista_llr"
        [rd] = fista_llr(E, dd, lambda, [1 1 1]*patch_size, [E.Nd, E.Nt], niter);
    end

    % 6. save
    outfname = ['/home/fs0/qijia/scratch/moco_exp/expout/test_alg/', optalg, '-', num2str(lambda), '-', num2str(patch_size), '-', num2str(niter), '-', num2str(rho)]
    save_avw(abs(rd), outfname, 'd', scales)
end
function [S, I]=calc_flow_rate(param_folder, vessel_mask_path, bias_field_path)
    % 1. Estimate A, dt, s, p within vessel mask M
    %    load in, alreay estimated here
    addpath('/home/fs0/qijia/code/CAPRIAModel')
    addpath('/home/fs0/qijia/code/DynAngioQuant/Dynamic_Angio')
    [img,~,scales,~,~] = read_avw(char(vessel_mask_path));
    M = logical(img);
    [img,~,scales,~,~] = read_avw(bias_field_path);
    b = img;
    [img,~,scales,~,~] = read_avw([char(param_folder) '/mean_fblood.nii.gz']);
    A = img;
    A = A./b;
    As = A(M);
    [img,~,scales,~,~] = read_avw([char(param_folder) '/mean_disp_p.nii.gz']);
    p = img;
    ps = p(M)*0.5;
    [img,~,scales,~,~] = read_avw([char(param_folder) '/mean_disp_s.nii.gz']);
    s = img;
    ss = s(M)*0.1;
    [img,~,scales,~,~] = read_avw([char(param_folder) '/mean_deltblood.nii.gz']);
    dt = img;
    dts = dt(M);

    % 2. Average A across vessel mask M and divide by voxel size mm^3 get S_0
    %     erodeing the mask M, to avoid partial volume effect, 
    %     also, do bias field correction from MPRAGE-T1 image using fsl_anat
    SE = strel('sphere', 1);
    eM = imerode(M, SE);
    S0 = mean(A(eM))/prod(scales)*1e3;
    % 3. Simulate a dynamic image I using DynAngioTheoreticalIntGammaDeltaTMin without RF attenuation with A,dt,s,p , the temporal resolution and other parameters are the same as what we used for generating dictionary for subspace.
    tau = 0.0001;
    [dMs] = simulate_angio(As, dts, ps, ss, 1, 1, tau); % dMs: Nt, Ns
    
    % 4. We calculate the summation of simulated signal intensity within each frame and each vessel territory mask M_i , so we get S_i curve with temporal resolution same as the subspace temporal resolution.
    S = sum(dMs,2) / tau / S0; % Nt, 1

    I = zeros([size(M), size(dMs,1)]);
    M = repmat(M(:), [1,1,1,size(dMs,1)]);
    I(M) = dMs';
    % 5. the flow rate F_i is then the plateau of curve S_i/S_0/\tau
    figure;
    plot(S, 'LineWidth', 2);
    set(gca,'FontSize',20);
    % set xticks
    % xticks([])
end
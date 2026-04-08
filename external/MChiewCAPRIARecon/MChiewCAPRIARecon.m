% Test Mark Chiew's advanced recon tools on CAPRIA data

function MChiewCAPRIARecon(RawDir,MeasID,OutDir,OutName,Seq2D,TempResn,FracDataToUse,Nx,Ny,Nz,Nr,Nc,L,flags,SpatialMtxSz,shift,DispResults,SensitivityThresh,SeqType,PhaseCorr,FrameNos,FrameNosForSensCalc,SensKernelSize,HannFilterFrac,SensCpDir,PreCompressCoils,IsHalfSpoke)

if nargin < 13 || isempty(L)
    L = [];
end
if nargin < 14 || isempty(flags)
    flags = [];
end
if nargin < 15
    SpatialMtxSz = [];
end
if nargin < 16 || isempty(shift)
    shift = [];
end
if nargin < 17 || isempty(DispResults)
    DispResults = false;
end
if nargin < 18 || isempty(SensitivityThresh)
    SensitivityThresh = 0.1;
end
if nargin < 19 || isempty(SeqType)
    SeqType = [];
end
if nargin < 20 || isempty(PhaseCorr)
    PhaseCorr = true;
end
if nargin < 21 || isempty(FrameNos)
    FrameNos = [];
end
if nargin < 22 || isempty(FrameNosForSensCalc)
    FrameNosForSensCalc = [];
end
if nargin < 23 || isempty(SensKernelSize)
    SensKernelSize = 5;
end
if nargin < 24 || isempty(HannFilterFrac)
    HannFilterFrac = 1;
end
if nargin < 25 || isempty(SensCpDir)
    SensCpDir = [];
end
if nargin < 26 || isempty(PreCompressCoils)
    PreCompressCoils = false;
end
if nargin < 27 || isempty(IsHalfSpoke)
    IsHalfSpoke = false;
end

%% Deal with optional parameters in fields

% Regularisation parameters
Ldef.S = 1E4*[1 1 1 1]; % SENSE
Ldef.L2.x  =   1E-2;
Ldef.L2.t  =   1E4;
Ldef.xf    =   1E-4;
Ldef.LLR.x =   1E-2;
Ldef.LLR.p =   5;
Ldef.xTV   =   1E-3;
Ldef.xTVtL2.x = 1E-3;
Ldef.xTVtL2.t = 1E4;
Ldef.LnS.L = 5E-9;
Ldef.LnS.S = 2E-10;

L = topassargs(L,Ldef,true,true);

% Flags
flagsdef.regrid = true;
flagsdef.calc_anat = true;
flagsdef.calc_sens = true;
flagsdef.sense  = true;
flagsdef.L2     = true;
flagsdef.xf     = true;
flagsdef.reconmean = false;
flagsdef.recontag = false;
flagsdef.reconcontrol = false;
flagsdef.LLR    = true;
flagsdef.xTV    = true;
flagsdef.xTVtL2 = true;
flagsdef.LnS    = true;

flags = topassargs(flags,flagsdef,true,true);


    
%% Create output directories
if ~exist(OutDir)
    disp(['Output directory ' OutDir ' does not exist: creating...'])
    mkdir(OutDir);
end
OutSubDir = [OutDir '/' OutName];
if ~exist(OutSubDir)
    disp(['Output directory ' OutSubDir ' does not exist: creating...'])
    mkdir(OutSubDir);
end

%% Display the inputs for the log file and save
ReconStartDateTime = datetime; 
disp(ReconStartDateTime)
disp('>>> Starting MChiewCAPRIARecon')
disp('> Using the following parameters:')
disp(['RawDir = ' ns(RawDir)])
disp(['MeasID = ' ns(MeasID)])
disp(['OutDir = ' ns(OutDir)])
disp(['OutName = ' ns(OutName)])
disp(['Seq2D = ' ns(Seq2D)])
disp(['TempResn = ' ns(TempResn)])
disp(['FracDataToUse = ' ns(FracDataToUse)])
disp(['Nx = ' ns(Nx)])
disp(['Ny = ' ns(Ny)])
disp(['Nz = ' ns(Nz)])
disp(['Nr = ' ns(Nr)])
disp(['Nc = ' ns(Nc)])
disp(['L = '])
disp(L)
disp(['flags = '])
disp(flags)
disp(['SpatialMtxSz = ' ns(SpatialMtxSz)])
disp(['shift = ' ns(shift)])
disp(['DispResults = ' ns(DispResults)])
disp(['SensitivityThresh = ' ns(SensitivityThresh)])
disp(['SeqType = ' ns(SeqType)])
disp(['PhaseCorr = ' ns(PhaseCorr)])
disp(['FrameNos = ' ns(FrameNos)])
disp(['FrameNosForSensCalc = ' ns(FrameNosForSensCalc)])
disp(['SensKernelSize = ' ns(SensKernelSize)])
disp(['HannFilterFrac = ' ns(HannFilterFrac)])
disp(['SensCpDir = ' SensCpDir])
disp(['PreCompressCoils = ' ns(PreCompressCoils)])

save([OutSubDir '/params.mat']);

%% Copy anat and sens data from another directory if requested
CurDir = pwd;
if ~isempty(SensCpDir)
    disp(['Creating symbolic links to previous anat and sens data inside ' SensCpDir '...'])
    cd(OutSubDir)
    
    % Sanity check
    if ~exist(['../' SensCpDir])
        error(['Could not find directory to copy data from: ' SensCpDir])
    end
    
    if exist(['../' SensCpDir '/params.mat'])
       tmp = load('params.mat');
       newparams = [Nx,Ny,Nz,Nr,SpatialMtxSz,shift];
       cpparams = [tmp.Nx,tmp.Ny,tmp.Nz,tmp.Nr,tmp.SpatialMtxSz,tmp.shift];
       if sum(newparams ~= cpparams) > 0
           disp(['Current critical parameters: ' newparams])
           disp(['Copy critical parameters: ' cpparams])
           error('Critical parameters do not match - cannot copy sens/anat data - aborting')
       end
    else
       warning('Sens copy directory does not contain params.mat - assuming parameters match...') 
    end
    tosystem(['ln -s ../' SensCpDir '/anat.mat'])
    tosystem(['ln -s ../' SensCpDir '/sens.mat'])
    cd(CurDir)
end

%% Get into the raw data directory
cd(RawDir)

%% Read in data
disp('Reading in data...')
tic
[kdata,k,S,CentreSlcOffset,scales] = ExtractCAPRIAData(MeasID,Seq2D,TempResn,FracDataToUse,false,SpatialMtxSz,SeqType,PhaseCorr,FrameNos,[],IsHalfSpoke);
kdata_mean = mean(kdata,4);
if flags.reconmean
    kdata_diff = kdata_mean;
elseif flags.recontag
    kdata_diff = kdata(:,:,:,1);
elseif flags.reconcontrol
    kdata_diff = kdata(:,:,:,2);
else
    kdata_diff = kdata(:,:,:,2)-kdata(:,:,:,1);
end
clear kdata;
t = toc; disp(['-- Data reading took ' ns(t/60/60) ' hours'])

%% Specify parameters and reshape
NcOrig = size(kdata_mean,3);
Nt = size(kdata_mean,2);
%Nx = 192; Ny = 192; Nz = 1;
%Nr = 192*2;
if Seq2D
    Ndims = 2;
else
    Ndims = 3;
end

% If not specified, use all frames for coil sensitivity calculations
if isempty(FrameNosForSensCalc)
    FrameNosForSensCalc = 1:Nt;
end

%% Pre-compress coils if requested
if PreCompressCoils
    tic
    disp('Pre-compressing coils...')
    % Calculate the transformation to compress the coils
    [~, xfm, ~] = calc_psens(reshape(kdata_mean(:,FrameNosForSensCalc,:),[],NcOrig));
    
    % Apply the coil compression to the difference and mean data
    kdata_diff = apply_sens_xfm(xfm, kdata_diff,Nc,3);
    kdata_mean = apply_sens_xfm(xfm, kdata_mean,Nc,3);
    
    % Reset the number of coils for later processing
    NcOrig = Nc;
    
    t = toc; disp(['-- Coil pre-compression took ' ns(t/60/60) ' hours'])
end

%% Calculate a rough anatomical image from mean data
cd(CurDir); cd(OutDir); cd(OutName);

if exist('./anat.mat')
    tic
    disp('Loading anat data...')
    load ./anat.mat
    t = toc; disp(['-- Anat loading took ' ns(t/60/60) ' hours'])
elseif flags.calc_anat
    tic
    disp('Constructing anatomical image...')
    if isempty(shift)
        E = xfm_NUFFT([Nx, Ny, Nz, 1],[],[],reshape(k(:,FrameNosForSensCalc,:),[],1,Ndims),'wi',1,'table',true); 
    else
        E = xfm_NUFFT([Nx, Ny, Nz, 1],[],[],reshape(k(:,FrameNosForSensCalc,:),[],1,Ndims),'wi',1,'shift',shift,'table',true);
    end
    
    % Apply a Hann filter to smooth the data - no high res info needed for
    % coil sensitivity estimation
    Nf = round(Nr*HannFilterFrac); % Shrink the filter if requested
    if mod(Nf,2) == 0; Nf = Nf - 1; end % Make sure it's odd, so we can centre about k = 0
    kcentreIdx = ceil((Nr+1)/2); % Find the k=0 index
    fIdx = (kcentreIdx - floor(Nf/2)):(kcentreIdx + floor(Nf/2)); % Calculate the index centred about this point
    
    % Calculate the filter
    %F = hann(Nr);
    F = zeros(Nr,1);
    F(fIdx) = hann(Nf);
    
    % Modify to cope with partial Fourier
    if S(1) < Nr % Asymmetric echo was used, so just keep the end part of the filter
        F = F((Nr-S(1)+1):end);
    end
    kdata_mean = reshape(reshape(kdata_mean(:,FrameNosForSensCalc,:),length(F),[],NcOrig).*F,[],NcOrig);
    
    for i = 1:NcOrig
        disp(['Regridding coil ' ns(i)])
        m(:,i) = E.iter(kdata_mean(:,i),@pcg,1E-4,50,[1E3,1E3,1E3,0]);
    end
    m = reshape(m,[E.Nd NcOrig]);
    
    % Display and save
    SoSM = sos(m);
    if DispResults
        DispIm(squeeze(flip(SoSM,1))); title 'Anat'
    end
    
    q = matfile('anat','Writable',true);
    q.m = m;
    q.anat = SoSM;
    
    % Save to Nifti
    SaveDynAngioRaw(SoSM,'anat',scales,false,CentreSlcOffset);
    
    t = toc; disp(['-- Anatomical construction took ' ns(t/60/60) ' hours'])
else
    disp('Skipping anatomical image construction...')
end

% Save memory
clear E kdata_mean

%% Estimate Sensitivities and Compress
if exist('./sens.mat')
    tic
    disp('Loading sensitivity data...')
    load ./sens.mat
    t = toc; disp(['-- Sens loading took ' ns(t/60/60) ' hours'])
elseif flags.calc_sens
    % NB. 'thresh' originally 0.1, but this seems to miss some areas with
    % signal, so reduced here
    tic
    disp('Estimating coil sensitivities...')
    sens = adaptive_estimate_sens('data',m,'kernel',SensKernelSize,'thresh',SensitivityThresh,'verbose',true);
    
    save('sens','sens','-v7.3');
    
    SaveDynAngioRaw(sens,'sens',scales,false,CentreSlcOffset);
    
    t = toc; disp(['-- Coil sensitivity estimation took ' ns(t/60/60) ' hours'])
    
else % Don't calculate sensitivities
    disp('Skipping coil sensitivity calculation...')
    sens = [];
end

if isempty(sens) % No sensitivity calculation
    ps = []; % Leave compressed coil info empty
    pd = kdata_diff; % Just copy the kspace data without compression
    Nc = size(pd,3); % Reset the number of coils to be the full set of physical coils
else
    if ~PreCompressCoils % If we haven't used pre-compression, compress here
        tic
        disp('Calculating compressed coils...')
        [ps, xfm, ~] = calc_psens(sens);
    
        disp('Applying coil sensitivites...')
        pd = apply_sens_xfm(xfm, kdata_diff,Nc,3);
        
        t = toc; disp(['-- Coil compression and application took ' ns(t/60/60) ' hours'])
        
    else % Otherwise, just copy the data, which is already compressed
        disp('No coil compression needed at this stage as performed previously');
        ps = sens;
        pd = kdata_diff;
    end
    
    
end

% Save memory
clear m sens kdata_diff xfm

%% Regridding for comparison
if exist('./resr.mat')
    disp('Regridding recon already done...')
%    load('resr.mat');
elseif flags.regrid
    tic
    disp('Performing regridding reconstruction...')
    if isempty(shift)
        E0 = xfm_NUFFT([Nx,Ny,Nz,Nt],[], [], k,'table',true);
    else
        E0 = xfm_NUFFT([Nx,Ny,Nz,Nt],[], [], k,'shift',shift,'table',true);
    end
    
    for i = 1:Nc
        disp(['Regridding coil ' ns(i) ' of ' ns(Nc)])
        imgr(:,:,:,i) = E0'*(pd(:,:,i).*E0.w);
    end
    imgr = reshape(imgr,[E0.Nd E0.Nt Nc]);
    
    if isempty(ps) % Use sum of squares
        imgr = sos(imgr);
    else % We have coil information, so do Roemer combination    
        imgr = sum(imgr.*conj(reshape(ps(:,:,:,1:Nc),[E0.Nd 1 Nc])),5)./sum(ps(:,:,:,1:Nc).*conj(ps(:,:,:,1:Nc)),4);
    end
    
    save('resr','imgr','-v7.3')
    SaveDynAngioRaw(abs(imgr),'resr',scales,false,CentreSlcOffset);
    
    t = toc; disp(['-- Regridding recon took ' ns(t/60/60) ' hours'])
    
    if DispResults
        DispIm(mean(flip(imgr(:,:,1:ceil(end/10):end,:),1),4),1,99.5); title 'Regridding temporal mean'
        DispIm(flip(squeeze(imgr(:,:,1:ceil(end/10):end,1:ceil(end/4):end)),1),1,99.5); title 'Regridding'
    end
else
    imgr = [];
end

% Save memory
clear E0 imgr

%% Pre-calculate stuff for memory savings
if flags.sense || flags.L2 || flags.xf || flags.LLR
    tic
    disp('Pre-calculations for memory savings...')
    
    if exist('./data.mat')
        disp('Loading data...')
        load ./data.mat
        
        % Recreate the encoding operator, E, from saved data (this is faster than recreating from scratch):
        if isempty(shift)
            E = xfm_NUFFT([Nx,Ny,Nz,Nt],ps(:,:,:,1:Nc), [], k, 'wi',1,'table',true, 'st', [], 'PSF', PSF);
        else
            E = xfm_NUFFT([Nx,Ny,Nz,Nt],ps(:,:,:,1:Nc), [], k, 'wi',1,'shift',shift,'table',true, 'st', [], 'PSF', PSF);
        end
        
    else
       
        % Generate the encoding operator
        if isempty(shift)
            E = xfm_NUFFT([Nx,Ny,Nz,Nt],ps(:,:,:,1:Nc), [], k, 'wi',1,'table',true);
        else
            E = xfm_NUFFT([Nx,Ny,Nz,Nt],ps(:,:,:,1:Nc), [], k, 'wi',1,'shift',shift,'table',true);
        end
        
        q = matfile('./data','Writable',true);
        dd = E'*pd(:,:,1:Nc);
        
        q.dd = dd;
        q.PSF = E.PSF;
    end
    
    t = toc; disp(['-- Precalculations took ' ns(t/60/60) ' hours'])
end

% Clear unnecessary variables - these are all encapsulated inside E now
clear ps pd k PSF

%% Example linear recon (~cgsense w/ regularisation)
if exist('./resS.mat')
    disp('SENSE recon already done...')
    %load('resS.mat');
elseif flags.sense
    disp('Performing SENSE recon...')
    %Regularisation terms in x, y, z and t
    % Lx = 1E4;
    % Ly = 1E4;
    % Lz = 1E4;
    % Lt = 1E4;
    Nits = 100;
    
    % Time how long one iteration takes, then use this to predict the full
    % computational time
    tic; 
    E.iter(dd, @pcg, 1E-4, 1, L.S); 
    OneIt = toc; 
    disp(['One iteration took ' ns(OneIt) ' s. Estimated time for ' ns(Nits) ' iterations is ' ns(OneIt*Nits) ' s = ' ns(OneIt*Nits/60/60) ' hrs'])
    
    tic
    imgS = E.iter(dd, @pcg, 1E-4, Nits, L.S);
    imgS = reshape(imgS,[E.Nd E.Nt]);
    
    save('resS','imgS','-v7.3')
    SaveDynAngioRaw(abs(imgS),'resS',scales,false,CentreSlcOffset);

    t = toc; disp(['-- SENSE recon took ' ns(t/60/60) ' hours'])
    
    % Display
    if DispResults
        DispIm(mean(flip(imgS(:,:,1:ceil(end/10):end,:),1),4),1,99.5); title 'SENSE temporal mean'
        DispIm(flip(squeeze(imgS(:,:,1:ceil(end/10):end,1:ceil(end/4):end)),1),1,99.5); title 'SENSE'
    end
else
    imgS = [];
end

% Save memory
clear imgS

%% Example non-linear recon (x-sparse + temporal L2 smoothness)
if exist('./resL2.mat')
    disp('L2 recon already done...')
    %load('resL2.mat');
elseif flags.L2
    tic
    disp('Performing L2 recon...')
    % Lx  =   1E-2;
    % Lt  =   1E4; %1E6;
    
    iter    =   200;
    disp('Calculating step size...')
    step = E.max_step()/2;
    %step    =   1.5E-8; % Shouldn't be bigger than E.max_step(), which is ~1.5e-7 here
    
    imgL2 =   fista_L2(E, dd, L.L2.x, L.L2.t, [prod(E.Nd) E.Nt], iter, step);
    imgL2 =   reshape(imgL2,[E.Nd E.Nt]);
    
    save('resL2','imgL2','-v7.3')
    SaveDynAngioRaw(abs(imgL2),'resL2',scales,false,CentreSlcOffset);

    t = toc; disp(['-- L2 recon took ' ns(t/60/60) ' hours'])

    % Display
    if DispResults
        DispIm(mean(flip(imgL2(:,:,1:ceil(end/10):end,:),1),4),1,99.5); title 'L2 temporal mean'
        DispIm(flip(squeeze(imgL2(:,:,1:ceil(end/10):end,1:ceil(end/4):end)),1),1,99.5); title 'L2'        
    end

else
    imgL2 = [];
end

% Save memory
clear imgL2

%% Example non-linear recon (xf-sparse)
if exist('./resxf.mat')
    disp('xf recon already done...')
    %load('resxf.mat');
elseif flags.xf
    tic
    disp('Performing xf recon...')
    %L   =   1E-4;
    
    iter    =   200;
    if ~exist('step','var')
        disp('Calculating step size...')
%     step    =   1.5E-8; % Shouldn't be bigger than E.max_step(), which is ~1.5e-7 here
        step = E.max_step()/2;  
    end
    
    imgxf =   fista_xf(E, dd, L.xf, [prod(E.Nd) E.Nt], iter, step);
    imgxf =   reshape(imgxf,[E.Nd E.Nt]);
    
    save('resxf','imgxf','-v7.3');
    SaveDynAngioRaw(abs(imgxf),'resxf',scales,false,CentreSlcOffset);
    
    t = toc; disp(['-- xf recon took ' ns(t/60/60) ' hours'])

    % Display
    if DispResults
        DispIm(mean(flip(imgxf(:,:,1:ceil(end/10):end,:),1),4),1,99.5); title 'xf temporal mean'
        DispIm(flip(squeeze(imgxf(:,:,1:ceil(end/10):end,1:ceil(end/4):end)),1),1,99.5); title 'xf'        
    end
    
else 
    imgxf = [];
end

%% Locally Low Rank (LLR) recon
if exist('./resLLR.mat')
    disp('LLR recon already done...')
    %load('resLLR.mat');
elseif flags.LLR
    tic
    disp('Performing LLR recon...')
    
    iter    =   200;
    
    imgLLR =   pogm_LLR(E, dd, L.LLR.x, [1 1 1]*L.LLR.p, [E.Nd E.Nt], iter);
    imgLLR =   reshape(imgLLR,[E.Nd E.Nt]);
    
    save('resLLR','imgLLR','-v7.3');
    SaveDynAngioRaw(abs(imgLLR),'resLLR',scales,false,CentreSlcOffset);
    
    t = toc; disp(['-- LLR recon took ' ns(t/60/60) ' hours'])

    % Display
    if DispResults
        DispIm(mean(flip(imgLLR(:,:,1:ceil(end/10):end,:),1),4),1,99.5); title 'LLR temporal mean'
        DispIm(flip(squeeze(imgLLR(:,:,1:ceil(end/10):end,1:ceil(end/4):end)),1),1,99.5); title 'LLR'        
    end
    
else 
    imgLLR = [];
end

%% Spatial total variation (xTV) recon
if exist('./resxTV.mat')
    disp('xTV recon already done...')
    
elseif flags.xTV
    tic
    disp('Performing xTV recon...')
    
    iter    =   100;
    
    imgxTV =   fgp_xTV(E, dd, L.xTV, iter);
    imgxTV =   reshape(imgxTV,[E.Nd E.Nt]);
    
    save('resxTV','imgxTV','-v7.3');
    SaveDynAngioRaw(abs(imgxTV),'resxTV',scales,false,CentreSlcOffset);
    
    t = toc; disp(['-- xTV recon took ' ns(t/60/60) ' hours'])

    % Display
    if DispResults
        DispIm(mean(flip(imgxTV(:,:,1:ceil(end/10):end,:),1),4),1,99.5); title 'xTV temporal mean'
        DispIm(flip(squeeze(imgxTV(:,:,1:ceil(end/10):end,1:ceil(end/4):end)),1),1,99.5); title 'xTV'        
    end
    
else 
    imgxTV = [];
end


%% Spatial total variation (xTV) + L2 over time recon
if exist('./resxTVtL2.mat')
    disp('xTVtL2 recon already done...')
    
elseif flags.xTVtL2
    tic
    disp('Performing xTVtL2 recon...')
    
    iter    =   100;
    
    imgxTVtL2 =   fgp_xTV_tL2(E, dd, L.xTVtL2.x, L.xTVtL2.t, iter);
    imgxTVtL2 =   reshape(imgxTVtL2,[E.Nd E.Nt]);
    
    save('resxTVtL2','imgxTVtL2','-v7.3');
    SaveDynAngioRaw(abs(imgxTVtL2),'resxTVtL2',scales,false,CentreSlcOffset);

    t = toc; disp(['-- xTVtL2 recon took ' ns(t/60/60) ' hours'])

    % Display
    if DispResults
        DispIm(mean(flip(imgxTVtL2(:,:,1:ceil(end/10):end,:),1),4),1,99.5); title 'xTVtL2 temporal mean'
        DispIm(flip(squeeze(imgxTVtL2(:,:,1:ceil(end/10):end,1:ceil(end/4):end)),1),1,99.5); title 'xTVtL2'        
    end
    
else 
    imgxTVtL2 = [];
end

%% Low rank and sparse recon
if exist('./resLnS.mat')
    disp('L+S recon already done...')
    
elseif flags.LnS
    tic
    disp('Performing L+S recon...')
    
    iter    =   100;
    
    [imgLnS_L,imgLnS_S] =   pogm_LS(E, dd, L.LnS.L, L.LnS.S, [E.Nd E.Nt], iter);
    
    imgLnS =   reshape(imgLnS_L + imgLnS_S,[E.Nd E.Nt]);
    clear imgLnS_L imgLnS_S
    
    save('resLnS','imgLnS','-v7.3');
    SaveDynAngioRaw(abs(imgLnS),'resLnS',scales,false,CentreSlcOffset);
    
    t = toc; disp(['-- L+S recon took ' ns(t/60/60) ' hours'])

    % Display
    if DispResults
        DispIm(mean(flip(imgLnS(:,:,1:ceil(end/10):end,:),1),4),1,99.5); title 'LnS temporal mean'
        DispIm(flip(squeeze(imgLnS(:,:,1:ceil(end/10):end,1:ceil(end/4):end)),1),1,99.5); title 'LnS'        
    end
    
else 
    imgLnS = [];
end



%% Finish!

cd(CurDir)
disp('DONE!')

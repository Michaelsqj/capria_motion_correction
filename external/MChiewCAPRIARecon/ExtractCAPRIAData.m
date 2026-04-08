function [kdataframe, kspace, S, CentreSlcOffset, Resn] = ExtractCAPRIAData(MeasFileID, Seq2D, TempResn, FracDataToUse, subtract, SpatialMtxSz, SeqType, PhaseCorr, FrameNos, ReshapeOutput, IsHalfSpoke)

if nargin < 10 || isempty(ReshapeOutput); ReshapeOutput = true; end % Concenates k-space data across RO columns and spokes
if nargin < 11 || isempty(IsHalfSpoke); IsHalfSpoke = false; end

%MeasFileID='3D/meas_MID284_GR3D_GRE_FA6_TR9_FOV183_Mtx160_AsymEcho_to_CAPIASL_CV_nce_angio_FID23873.dat';
%TempResn=1; %in ms
%SpatialMtxSz=192;
PreSubtractData = false; 
UseConjGradRecon = false; 
MaxIts = 100; 
%FrameNos = []; 
UseAdaptiveCombine = false; 
%SeqType = []; 
SaveAllCoils = false; 
if nargin < 4
    FracDataToUse = 1; 
end
if nargin < 5 
    subtract = true;
end
if nargin < 6
    SpatialMtxSz = [];
end
if nargin < 7
    SeqType = [];
end
if nargin < 8
    PhaseCorr = true;
end
if nargin  < 9
    FrameNos = [];
end

% Read the raw data headers
twix_obj = mapVBVD(MeasFileID,'ignoreSeg',true,'removeOS',false);
if numel(twix_obj) > 1
    twix_obj = twix_obj{end};
end

SeqName = twix_obj.hdr.Config.SequenceFileName;
disp(['Sequence used was: ' SeqName])

switch SeqName
    case {'%CustomerSeq%\to_CAPIASL_CV_nce_angio','%CustomerSeq%\to_CV_VEPCASL'} % Original version
        
        % Determine the data type: 1 = linear, 2 = 2D GR, 3 = 3D GR
        if isempty(SeqType)
            SeqType = twix_obj.hdr.MeasYaps.sWiPMemBlock.alFree{12+1};
        else
            % SeqType is provided - useful for old data where the above parameter isn't
            % defined in the same way.
        end
        
        switch SeqType
            case 1
                Seq2D = true;
                SeqGR = false;
                SeqSong = false;
                
            case 2
                Seq2D = true;
                SeqGR = true;
                SeqSong = false;
                
            case 4
                Seq2D = false;
                SeqGR = true;
                SeqSong = false;
                
            case 24
                Seq2D = true;
                SeqGR = true;
                SeqSong = true;
                
            otherwise
                error(['SeqType = ' ns(twix_obj.hdr.MeasYaps.sWiPMemBlock.alFree{12+1}) ': not recognised!']);
        end

        % For this older sequence, variable spokes and paired encodings were not used
        SeqVarSpokes = false; SeqPairedEncs = false;
        
    case {'%CustomerSeq%\to_CV_VEPCASL_v0p2','%CustomerSeq%\to_CV_VEPCASL_v0p3'}
        
        % WIP mem block position, as defined in the sequence code, to
        % Matlab index conversion:
        % +1 for C++ vs. Matlab indexing
        % +2 for reserved WIP mem block positioned used elsewhere in the sequence
        % +WIPMemBlock starting position (7 for trajectory boolean parameters)
        % +Position within the boolean array
        % NB. False yields an empty array, true yields 1
        Seq2D = isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 7 + 0});
        if Seq2D disp('Sequence is 2D'); else disp('Sequence is 3D'); end
        
        SeqGR = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 7 + 1});
        if SeqGR disp('Sequence uses GR'); else disp('Sequence does not use GR'); end
        
        SeqSong = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 7 + 2});
        if SeqSong disp('Sequence uses Song ordering'); else disp('Sequence does not use Song ordering'); end
        
        SeqVarSpokes = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 7 + 3});
        if SeqVarSpokes disp('Sequence uses variable spokes'); else disp('Sequence does not use variable spokes'); end
        
        SeqPairedEncs = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 7 + 4});
        if SeqPairedEncs disp('Sequence uses paired encodings'); else disp('Sequence does not use paired encodings'); end

case {'%CustomerSeq%\to_CV_VEPCASL_v0p4'}
        
        % WIP mem block position, as defined in the sequence code, to
        % Matlab index conversion:
        % +1 for C++ vs. Matlab indexing
        % +2 for reserved WIP mem block positioned used elsewhere in the sequence
        % +WIPMemBlock starting position (8 for trajectory boolean parameters)
        % +Position within the boolean array
        % NB. False yields an empty array, true yields 1
        Seq2D = isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 8 + 0});
        if Seq2D disp('Sequence is 2D'); else disp('Sequence is 3D'); end
        
        SeqGR = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 8 + 1});
        if SeqGR disp('Sequence uses GR'); else disp('Sequence does not use GR'); end
        
        SeqSong = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 8 + 2});
        if SeqSong disp('Sequence uses Song ordering'); else disp('Sequence does not use Song ordering'); end
        
        SeqVarSpokes = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 8 + 3});
        if SeqVarSpokes disp('Sequence uses variable spokes'); else disp('Sequence does not use variable spokes'); end
        
        SeqPairedEncs = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 8 + 4});
        if SeqPairedEncs disp('Sequence uses paired encodings'); else disp('Sequence does not use paired encodings'); end

case {'%CustomerSeq%\to_CV_VEPCASL_v0p6','%CustomerSeq%\to_CV_VEPCASL_v0p5','%CustomerSeq%\qijia_CV_VEPCASL_v0p4','%CustomerSeq%\qijia_CV_VEPCASL'}
        
        % WIP mem block position, as defined in the sequence code, to
        % Matlab index conversion:
        % +1 for C++ vs. Matlab indexing
        % +2 for reserved WIP mem block positioned used elsewhere in the sequence
        % +WIPMemBlock starting position (9 for trajectory boolean parameters)
        % +Position within the boolean array
        % NB. False yields an empty array, true yields 1
        Seq2D = isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 9 + 0});
        if Seq2D disp('Sequence is 2D'); else disp('Sequence is 3D'); end
        
        SeqGR = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 9 + 1});
        if SeqGR disp('Sequence uses GR'); else disp('Sequence does not use GR'); end
        
        SeqSong = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 9 + 2});
        if SeqSong disp('Sequence uses Song ordering'); else disp('Sequence does not use Song ordering'); end
        
        SeqVarSpokes = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 9 + 3});
        if SeqVarSpokes disp('Sequence uses variable spokes'); else disp('Sequence does not use variable spokes'); end
        
        SeqPairedEncs = ~isempty(twix_obj.hdr.MeasYaps.sWipMemBlock.alFree{1 + 2 + 9 + 4});
        if SeqPairedEncs disp('Sequence uses paired encodings'); else disp('Sequence does not use paired encodings'); end
                        
    otherwise
        disp('Unkonwn sequence version, using provided parameters')
        
end

% Extract info from the header
MaxTempResn = twix_obj.hdr.Config.TR/1000;% ms
Nsegs = twix_obj.hdr.Config.NSeg;
TotNSpokesInMaxTempResn = twix_obj.hdr.Config.RawLin;
NPhases = twix_obj.hdr.Config.NPhs;
FullMtxSz = twix_obj.hdr.Config.RawCol;
if nargin == 2
    TempResn = MaxTempResn;
end
if isempty(SpatialMtxSz)
    SpatialMtxSz = FullMtxSz/2;
end

% For non-golden ratio reconstructions, the temporal resolution is fixed
if (SeqGR == false) && (TempResn ~= MaxTempResn)
    warning(['Specified temporal resolution (' ns(TempResn) ') does not match the value set in the protocol: ' ns(MaxTempResn)])
    warning(['Reverting to protocol temporal resolution: ' ns(MaxTempResn)])
    TempResn = MaxTempResn;
end

% Determine the data points to use for reconstruction
kcentreIdx = ceil((FullMtxSz+1)/2);
if mod(round(SpatialMtxSz),2) ~=0    
    SpatialMtxSz = round(SpatialMtxSz)+1;
    disp(['Rounding spatial matrix size up to the nearest even number: ' (SpatialMtxSz)])
end
MtxSz = SpatialMtxSz * 2; % Account for RO oversampling
ColIdx = (kcentreIdx-MtxSz/2):(kcentreIdx+MtxSz/2-1);

% Calculate useful parameters
TR = MaxTempResn / Nsegs; % ms
Npreps = TotNSpokesInMaxTempResn / Nsegs;
disp([ns(Npreps) ' ASL preparations were used per encoding cycle'])
Nspokes = round(TempResn/TR);
NewTempResn = TR*Nspokes;
disp(['Rounding temporal resolution to ' ns(NewTempResn)]);
NSpokesPerPrep = Nsegs * NPhases;
T = NPhases * MaxTempResn;
NFrames = floor(NSpokesPerPrep/Nspokes);
disp(['This yields ' ns(NFrames) ' frames']);
VoxSz = twix_obj.hdr.Config.ReadFoV / MtxSz * 2; % Account for RO oversampling
if Seq2D
    SlcThk = twix_obj.hdr.Phoenix.sSliceArray.asSlice{1}.dThickness;
else
    SlcThk = VoxSz;
end
S = twix_obj.image.dataSize; % Grab the input data size

% Save out the voxel size (in mm) and temporal resolution (in s)
Resn = [VoxSz VoxSz SlcThk NewTempResn/1000];

% Save out the central slice offset
if isfield(twix_obj.hdr.Phoenix.sSliceArray.asSlice{1},'sPosition')
    SlicePos = twix_obj.hdr.Phoenix.sSliceArray.asSlice{1}.sPosition;
else
    disp('Could not find central slice location: assuming isocentre')
    SlicePos = [];
end

if isfield(SlicePos,'dSag'); Sag = SlicePos.dSag; else Sag = 0; end
if isfield(SlicePos,'dCor'); Cor = SlicePos.dCor; else Cor = 0; end
if isfield(SlicePos,'dTra'); Tra = SlicePos.dTra; else Tra = 0; end

CentreSlcOffset = [Sag Cor Tra];

% Cut the number of preps to use for recon if necessary
if length(FracDataToUse) > 1 % If we want to use less than 100% of the data with an offset, deal with that here
    FracDataOffset = FracDataToUse(2);
    FracDataToUse = FracDataToUse(1);
    
    % Check this makes sense (i.e. we don't try to read past the end of the
    % data
    if FracDataToUse + FracDataOffset > 1
        error(['FracDataToUse(' ns(FracDataToUse) ') + FracDataOffset (' ns(FracDataOffset) ') is greater than 1!!'])
    end
else
    FracDataOffset = 0;
end

% If we want to offset, calculate this first
NprepsOffset = round(Npreps * FracDataOffset);

% Now reset Npreps to be reduced if needed
if FracDataToUse ~=1
    disp(['Only using ' ns(round(Npreps * FracDataToUse)) ' of ' ns(Npreps) ' ASL preparations']);  
    disp(['Using an offset of ' ns(NprepsOffset) ' preps']);
    Npreps = round(Npreps * FracDataToUse);
end

% Constant trajectory parameters
if Seq2D && SeqGR % 2D golden ratio
    R = SpatialMtxSz * pi/2 / (Nspokes*Npreps);
    CGR = -(1-sqrt(5))/2; % Chan, MRM 2009
    
elseif Seq2D && ~SeqGR % 2D conventional radial
    R = SpatialMtxSz * pi/2 / (Nspokes*Npreps);
    PhiInc = pi/(Nspokes*Npreps);
    
else % 3D
    
    R = (SpatialMtxSz)^2 * pi/2 / (Nspokes*Npreps);
end
disp(['Undersampling factor = ' ns(R)])

KBSize = 6;
    
% Determine the frames to reconstruct
if isempty(FrameNos)
    FrameNos = 1:NFrames;
end

% Initialise the output
if Seq2D
    % Size: (x,y,coil,Partitions,Slices,Averages,CardiacPhases,...)
    %RadIm = zeros([MtxSz/2 MtxSz/2 S([2 4:6]) length(FrameNos) S(8:end)]);
else
    % Replace slices above with the output matrix size (assumes only one
    % slice acquired)
    %if S(5) > 1
    %    error('More than one slice detected with 3D data!')
    %end
    %RadIm = zeros([MtxSz/2 MtxSz/2 S([2 4]) MtxSz/2 S(6) length(FrameNos) S(8:end)]);
end

    
% Grab the raw data with the appropriate indices
disp('Reading in raw data...')
%kdataframe = zeros([length(ColIdx) S(2) length(Phi) S(4:6) length(FrameNos)]);

kspace=[];

% Assume the number of encoding cycles is the number of measurements * averages for now
NumberOfEncCycles = twix_obj.image.dataSize(6) * twix_obj.image.dataSize(9);
disp(['Assuming we have ' ns(NumberOfEncCycles) ' encoding cycles'])

%% Loop through the output images
for ii = 1:length(FrameNos)
    
    disp(['Getting kspace trajectory and data for frame ' ns(ii) ' of ' ns(length(FrameNos))])
    
    NFrame = FrameNos(ii);
    %disp(['Reconstructing frame ' ns(ii) ' of ' ns(length(FrameNos)) '...']);
    
    % Identify the actual spoke numbers relative to the start of the
    % readout that we want to grab here
    LinNos = ((NFrame-1)*Nspokes+1):(NFrame*Nspokes);
    % Empty the index of relevant line and phase numbers
    LinIdx = []; PhsIdx = [];
    
    EncIdx = 1; % Assume we are not using variable spokes for now, so all trajectories are the same for each encoding
    [LinIdx, PhsIdx, ColIdx, Phi, ~, kspace(:,ii,:)] = CalcCAPRIATraj([Npreps NprepsOffset], Nsegs, LinNos, EncIdx, SeqGR, Seq2D, MtxSz, FullMtxSz, S, ...
                                                                      SeqSong, SeqVarSpokes, SeqPairedEncs, NumberOfEncCycles, ...
                                                                      Nsegs, TotNSpokesInMaxTempResn,[],IsHalfSpoke);
%     % Loop through the preps, adding appropriate indices
%     for jj = 1:Npreps
%         
%         % Line number at the start of each cardiac phase
%         StartLinNo = (jj-1)*Nsegs + 1;
%         
%         LinIdx = [LinIdx (StartLinNo+mod(LinNos-1,Nsegs))];
%         PhsIdx = [PhsIdx (floor((LinNos-1)/Nsegs)+1)];
%         
%     end
%     
%     % Calculate the appropriate azimuthal and polar angles
%     if ~SeqGR % Standard radial ordering
%         Phi = (LinIdx - 1) * PhiInc;
%         
%         % If odd number of views, the sequence doubles the angles
%         if mod(length(Phi),2)~=0
%             Phi = Phi *2;
%         end
%         
%         Theta = [];
%         
%     else % Golden angle
%         if SeqSong % Golden angle increments down preps, then across lines
%             CurPrep = floor((LinIdx-1) / Nsegs);
%             StartLinNo = CurPrep * Nsegs;
%             GRCounter = CurPrep + (LinIdx-1 + (PhsIdx-1)*Nsegs - StartLinNo) * Npreps;
%             
%         else % Standard ordering
%             GRCounter = (LinIdx-1) + (PhsIdx-1) * Nsegs;
%         end
%         
%         if Seq2D
%             Phi = mod( GRCounter * CGR * pi, 2*pi );
%             Theta = [];
%         else
%             [Phi, Theta] = GoldenMeans3D(GRCounter,true);
%         end
%     end
%     
%     % Construct the trajectory
%     [kspace(:,ii,:), ColIdx] = CalcRadialKSpaceTraj(Phi,MtxSz,Theta,S(1),FullMtxSz);
    
    % Clear unnecessary variables to save on memory
    clear P tmp
    
    for kk = 1:length(Phi)
        % Dimensions of kdataframe: RO_cols  Coils  spokes  averages echoes measurements time
        kdataframe(:,:,kk,:,:,:,ii) = twix_obj.image(ColIdx,:,LinIdx(kk),:,:,:,PhsIdx(kk),:,:,:,:,:,:,:,:,:);
    end
end

nt  =   size(kdataframe,7);
kdataframe = reshape(permute(kdataframe,[1,2,3,7,4,5,6]),length(ColIdx), size(kdataframe,2),[],2);
% Dimensions of kdataframe: RO_cols  Coils  spokes/time averages/measurements (assumed to be 2 here)
kdataframe = permute(kdataframe,[1,3,2,4]);
OutTxt= 'Dimensions of kdataframe: RO_cols  spokes/time Coils averages/measurements (assumed to be 2 here)';
if PhaseCorr
    for i = 1:size(kdataframe,2)
        p=angle(mean(reshape(kdataframe(:,i,:,2).*conj(kdataframe(:,i,:,1)),[],1)));
        kdataframe(:,i,:,2)=kdataframe(:,i,:,2).*exp(-1j*p);
    end
end
if subtract
    kdataframe  =   kdataframe(:,:,:,2)-kdataframe(:,:,:,1);
    OutTxt= 'Dimensions of kdataframe: RO_cols  spokes/time Coils';
    if ReshapeOutput
        kdataframe  =   reshape(kdataframe,[],nt,size(kdataframe,3));
        OutTxt = 'Dimensions of kdataframe: RO_cols/spokes time Coils';
        kspace  =   reshape(kspace,[],nt,size(kspace,3));
        % Dimensions of kspace: RO_cols/spokes time 2/3 (for 2D/3D imaging)
        
    else % Keep dimensions easily accessible e.g. for debugging
        kdataframe  =   reshape(kdataframe,length(ColIdx),[],nt,size(kdataframe,3));
        OutTxt = 'Dimensions of kdataframe: RO_cols spokes time Coils';
        kspace  =   reshape(kspace,length(ColIdx),[],nt,size(kspace,3));
        % Dimensions of kspace: RO_cols spokes time 2/3 (for 2D/3D imaging)
    end
else
    disp('No Subtraction');
    
    if ReshapeOutput
        kdataframe  =   reshape(kdataframe,[],nt,size(kdataframe,3),2);
        OutTxt = 'Dimensions of kdataframe: RO_cols/spokes time Coils Averages/measurements (assumed to be 2)';
        kspace  =   reshape(kspace,[],nt,size(kspace,3));
        % Dimensions of kspace: RO_cols/spokes time 2/3 (for 2D/3D imaging)
    else
        kdataframe  =   reshape(kdataframe,length(ColIdx),[],nt,size(kdataframe,3),2);
        OutTxt = 'Dimensions of kdataframe: RO_cols spokes time Coils Averages/measurements (assumed to be 2)';
        kspace  =   reshape(kspace,length(ColIdx),[],nt,size(kspace,3));
        % Dimensions of kspace: RO_cols/spokes time 2/3 (for 2D/3D imaging)
    end
end
disp(OutTxt)

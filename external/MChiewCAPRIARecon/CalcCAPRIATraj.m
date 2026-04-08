function [LinIdx, PhsIdx, ColIdx, Phi, Theta, kspace, G, w, scale, PrepIdx] = ...
                        CalcCAPRIATraj(Npreps, Nsegs, LinNos, EncIdx, SeqGR, ...
                                       Seq2D, MtxSz, FullMtxSz, S, UseSongOrdering, ...
                                       UseVarSpokes, UsePairedEncs, NumberOfEncCycles, Segments, ProjectionsPerFrame, ...
                                       KBSize, IsHalfSpoke)

    if nargin < 16 || isempty(KBSize); KBSize = 6; end
    if nargin < 17 || isempty(IsHalfSpoke); IsHalfSpoke = false; end
    
    DebugFlag = false;
    
    % Check if an offset is required
    if length(Npreps) > 1
        NprepsOffset = Npreps(2);
        Npreps = Npreps(1);
    else
        NprepsOffset = 0;
    end
    
    % Useful numbers
    CGR = -(1-sqrt(5))/2; % Chan, MRM 2009
    PhiInc = pi/ProjectionsPerFrame; % For linear increments

    % Empty the index of relevant line and phase numbers
    LinIdx = []; PhsIdx = []; PrepIdx = [];
    
    % Loop through the preps, adding appropriate indices
    NprepStart = NprepsOffset + 1;
    for jj = NprepStart:(NprepStart+Npreps-1)
        
        % Line number at the start of each cardiac phase
        StartLinNo = (jj-1)*Nsegs + 1;
        
        LinIdx = [LinIdx (StartLinNo+mod(LinNos-1,Nsegs))];
        PhsIdx = [PhsIdx (floor((LinNos-1)/Nsegs)+1)];
        PrepIdx = [PrepIdx ones(1,length(LinNos))*jj];
    end
    
    % Calculate the appropriate azimuthal and polar angles
    if ~SeqGR % Standard radial ordering
        Phi = (LinIdx - 1) * PhiInc;
        
        % If odd number of views, the sequence doubles the angles
        if mod(length(Phi),2)~=0
            Phi = Phi *2;
        end
        
        Theta = [];
        
    else % Golden angle
        
        GRCounter = calculateGRCounter(LinIdx, PhsIdx, EncIdx, UseSongOrdering, UseVarSpokes, UsePairedEncs, NumberOfEncCycles, Segments, ProjectionsPerFrame);
        
        %GRCounter = (LinIdx-1) + (PhsIdx-1) * Nsegs;
        
        if Seq2D
            Phi = mod( GRCounter * CGR * pi, 2*pi );
            Theta = [];
        else
            [Phi, Theta] = GoldenMeans3D(GRCounter,true);
        end
    end
    
    % Construct the trajectory
    [kspace, ColIdx] = CalcRadialKSpaceTraj(Phi,MtxSz,Theta,S(1),FullMtxSz,IsHalfSpoke);
    
    % Change signs to get final image in the right orientation
    if Seq2D
        kspace = [-kspace(:,1) kspace(:,2)];
    else
        kspace = [-kspace(:,1) kspace(:,2) kspace(:,3)];
    end
        
    % Debugging
    if DebugFlag
        figure; scatter(kspace(:,1),kspace(:,2));
        axis equal
    end
    
    % Also set up forward operators etc. if needed
    if nargout > 6
        
        % Set up the NUFFT
        if Seq2D
            G = Gnufft({kspace, [MtxSz MtxSz], [1 1]*KBSize, 2*[MtxSz MtxSz], [MtxSz/2 MtxSz/2]});
        else % 3D
            G = Gnufft({kspace, [MtxSz MtxSz MtxSz], [1 1 1]*KBSize, 2*[MtxSz MtxSz MtxSz], [MtxSz/2 MtxSz/2 MtxSz/2]});
        end
        
    end
    
    if nargout > 7
        % Calculate the weights
        % NB. This is memory intensive for 3D imaging so calculate here before
        % reading in raw data
        % TODO: initialise with values that are proportional to abs(k) to help
        % convergence with fewer iterations?
        disp('Calculating weights')
        P = G.arg.st.p;
        w = ones([size(kspace,1) 1]);
        for kk=1:20
            disp(['Iteration ' ns(kk)])
            tmp = P * (P' * w);
            w = w ./ real(tmp);
        end
        
        % Clear unnecessary variables to save on memory
        clear P tmp
    end
    
    if nargout > 8
        % Calculate the scaling factor
        if Seq2D
            scale = G.arg.st.sn(end/2,end/2)^(-2) / prod(G.arg.st.Kd);
        else
            scale = G.arg.st.sn(end/2,end/2,end/2)^(-2) / prod(G.arg.st.Kd);
        end
    end
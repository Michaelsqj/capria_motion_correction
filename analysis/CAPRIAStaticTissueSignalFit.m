% Fit the CAPRIA static tissue signal to a T1 recovery model
function [M0, InvAlpha, T1, B1rel, fit, Ims_pc] = CAPRIAStaticTissueSignalFit(Ims,Mask,BGSMode,tau,BGStau1,FAMode,FAParams,t0,TR,Nsegs,Nphases,IncB1rel,initmaps,fitmethod,CostRescale)

if nargin < 3  || isempty(BGSMode); BGSMode = 'SI'; end
if nargin < 4  || isempty(tau); tau = 1.8; end
if nargin < 5  || isempty(BGStau1); BGStau1 = tau+2e-3+10e-3+11e-3/2; end
if nargin < 6  || isempty(FAMode); FAMode = 'quadratic'; end
if nargin < 7  || isempty(FAParams); FAParams = [2 9]; end
if nargin < 8  || isempty(t0); t0 = tau+2e-3+10e-3+11e-3+10e-3+2e-3; end
if nargin < 9  || isempty(TR); TR = 9.1e-3; end
if nargin < 10 || isempty(Nsegs); Nsegs = 36; end
if nargin < 11 || isempty(Nphases); Nphases = 6; end
if nargin < 12 || isempty(IncB1rel); IncB1rel = true; end
if nargin < 13 || isempty(initmaps); initmaps = []; end
if nargin < 14 || isempty(fitmethod); fitmethod = []; end
if nargin < 15 || isempty(CostRescale); CostRescale = 'voxel'; end

% Ensure the mask is logical
Mask = logical(Mask); Nvox = sum(Mask(:));

% Phase correct
Ims_pc = real(Ims.*exp(-1i*angle(Ims(:,:,:,end))));

% Bounds
if IncB1rel
    % params: [M0 InvAlpha T1 B1rel]
    lb = [0    0.5 100e-3 0.9];
    ub = [1e10 1.0 10.0   1.1];
else
    % params: [M0 InvAlpha T1]
    lb = [0    0.5 100e-3];
    ub = [1e10 1.0 10.0];
end

% Initialise
fit = zeros(size(Ims_pc));
M0 = zeros(size(Ims_pc(:,:,:,1)));
InvAlpha = M0;
T1 = M0;
B1rel = M0;

% Constrained optimisation options
opts.Display = 'off';
if ~isempty(fitmethod)
    disp(['Using fit method: ' fitmethod])
    opts.Algorithm = fitmethod; % e.g. 'sqp'
end
%opts.OptimalityTolerance = 1e-10;
%opts.FunctionTolerance = 1e-8;

% Loop through the data
VoxCount = 0;
for ii = 1:size(Ims_pc,1)
    %disp(['ii = ' ns(ii) ' of ' ns(size(Ims_pc,1)) ]);
    for jj = 1:size(Ims_pc,2)
        %disp(['jj = ' ns(jj) ' of ' ns(size(Ims_pc,2)) ]);
        for kk = 1:size(Ims_pc,3)
            
            if Mask(ii,jj,kk) == true
                disp([ns(VoxCount/Nvox*100) '% complete...'])
                %disp([ii jj kk])
                   
                % Rescale the cost function if needed
                if strcmpi(CostRescale,'global')
                    % Global scale factor for fitting to ensure values don't get too small
                    scale = max(Ims_pc(:));
                elseif strcmpi(CostRescale,'voxel')
                    % Try resetting scale for each voxel
                    scale = max(Ims_pc(ii,jj,kk,:));
                elseif strcmpi(CostRescale,'none')
                    % Don't rescale
                    scale = 1;
                else
                    error(['Unknown rescaling option: ' CostRescale]);
                end
                
                if IncB1rel
                    % Fit, accounting for VFA
%                     size(squeeze(Ims_pc(ii,jj,kk,:)))
%                     size(squeeze(CAPRIAStaticSignal(BGSMode,[BGStau1 0.9],FAMode,FAParams,t0,4.3,TR,Nsegs,Nphases)))
                    obfun = @(params) sum((squeeze(Ims_pc(ii,jj,kk,:))/scale - params(1)*squeeze(CAPRIAStaticSignal(BGSMode,[BGStau1 params(2)],FAMode,FAParams*params(4),t0,params(3),TR,Nsegs,Nphases))/scale).^2 );
                    
                else
                    % Fit, accounting for VFA
                    obfun = @(params) sum((squeeze(Ims_pc(ii,jj,kk,:))/scale - params(1)*squeeze(CAPRIAStaticSignal(BGSMode,[BGStau1 params(2)],FAMode,FAParams,t0,params(3),TR,Nsegs,Nphases))/scale).^2 );
                    
                end
                
                % Initialise parameters
                if isempty(initmaps)
                    if IncB1rel
                        params0 = [max(Ims_pc(ii,jj,kk,:)) 0.9 4.3 1.0];
                    else
                        params0 = [max(Ims_pc(ii,jj,kk,:)) 0.9 4.3];
                    end
                else % Use provided maps to intialise
                    if IncB1rel
                        params0 = [initmaps.M0(ii,jj,kk) initmaps.InvAlpha(ii,jj,kk) initmaps.T1(ii,jj,kk) initmaps.B1rel(ii,jj,kk)];
                    else
                        params0 = [initmaps.M0(ii,jj,kk) initmaps.InvAlpha(ii,jj,kk) initmaps.T1(ii,jj,kk)];
                    end
                    
                end

                % Constrained optimisation
                % Syntax: x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
                est = fmincon(obfun,params0,[],[],[],[],lb,ub,[],opts);
                
                params = est;
                if ~IncB1rel; params(4) = 1; end
                fit(ii,jj,kk,:) = params(1)*CAPRIAStaticSignal(BGSMode,[BGStau1 params(2)],FAMode,FAParams*params(4),t0,params(3),TR,Nsegs,Nphases);
                M0(ii,jj,kk) = params(1);
                InvAlpha(ii,jj,kk) = params(2);
                T1(ii,jj,kk) = params(3);
                B1rel(ii,jj,kk) = params(4);
                
                if (ii == 91) && (jj == 41)
                    disp('test')
                end
                VoxCount = VoxCount + 1;
            end
        end
    end
end
% Calculate the CAPRIA static tissue signal (relative to M0)
% function [Mxyav,Mxy,Mzminus] = CAPRIAStaticSignal(BGSMode,BGSParams,FAMode,FAParams,t0,T1,TR,Nsegs,Nphases)
function [Mxy]                 = CAPRIAStaticSignal(BGSMode,BGSParams,FAMode,FAParams,t0,T1,TR,Nsegs,Nphases)


% Find the number of TRs
NTRs = Nsegs*Nphases;

% Initialise
Mzminus = zeros(NTRs,1); Mzplus = Mzminus; Mxy = Mzminus;

% Calculate flip angle scheme
Alpha = CalcCAPRIAFAs(FAMode,FAParams,(1:NTRs)*TR,TR);

% Start with zero Mz (assume pre-sat)
Mz0 = 0;

% Find the Mz at the start of the readout
switch lower(BGSMode)
    case 'presat' % Pure T1 recovery
        Mzminus(1) = T1recovery(Mz0,t0,T1);
        
    case 'si' 
        
        % Extra parameters from the input
        BGStau1 = BGSParams(1);
        BGSAlphaInv = BGSParams(2);
        
        % T1 recovery until the inversion pulse
        Mzpre180 = T1recovery(Mz0,BGStau1,T1);
        
        % Inversion
        Mzpost180 = Mzpre180*(1-2*BGSAlphaInv);
        
        % T1 recovery until the readout
        Mzminus(1) = T1recovery(Mzpost180,t0-BGStau1,T1);
        
    case 'di'
        error('DI not yet implemented');
    otherwise
        error('Unknown BGSMode')
end
        
% Loop through the imaging RF pulses
for ii = 1:NTRs
    if ii > 1 % Calculate the Mz- unless we're on the first pulse
        % T1 recovery since the last  pulse
        Mzminus(ii) = T1recovery(Mzplus(ii-1),TR,T1);
    end
    
    % RF attenuation of Mz
    Mzplus(ii) = Mzminus(ii)*cos(todeg2rad(Alpha(ii)));
    
    % Transverse magnetisation created (from Mzminus)
    Mxy(ii) = Mzminus(ii)*sin(todeg2rad(Alpha(ii)));
end

% Average across phases
Mxyav = zeros(Nphases,1);
for ii = 1:Nphases
    Idx = ((ii-1)*Nsegs)+1:ii*Nsegs;
    Mxyav(ii) = mean(Mxy(Idx));
end

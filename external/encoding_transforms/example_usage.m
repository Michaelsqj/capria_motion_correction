% Example script for encoding transforms
% Mark Chiew
% mark.chiew@ndcn.ox.ac.uk
%
% Compiled 29/05/19
%
% These examples simply illustrate how these operators are initialised and
% how the forward/adjoint operations are performed. A simple conjugate
% gradient iterative reconstruction is built-in to the xfm base class. For
% more sophisticated use, see the image reconstruction tools at
% https://users.fmrib.ox.ac.uk/~mchiew/tools.html

%% xfm_FFT with R=2 random under-sampling
mask = true(64,64);                     % sampling mask
mask(randperm(64*64,64*64/2)) = false;  % sampling mask
E = xfm_FFT([64,64,1,1],[],[],'mask',mask);

x = phantom(64);

y = E*x;            % Forward Transform
z = E'*y;           % Adjoint Transform
z = E.mtimes2(x);   % equivalent to z = E'Ex

%% xfm_FFT with R=2 regular under-sampling and coil sensitivities
mask = true(64,64);         % sanpling mask
mask(2:2:end,:) = false;    % sanpling mask
load('sens');               % load coil sensitivities
E = xfm_FFT([64,64,1,1],sens,[],'mask',mask);

x = phantom(64);

y = E*x;            % Forward Transform
z = E'*y;           % Adjoint Transform
z = E.mtimes2(x);   % equivalent to z = E'Ex

out = E.iter(y,@pcg,1E-4,10);   % un-regularised cgSENSE 

%% xfm_FFT with R=2 regular under-sampling, coil sensitivities and B0
mask = true(64,64);         % sampling mask
mask(2:2:end,:) = false;    % sampling mask
load('sens');               % load coil sensitivities
b0 = zeros(64);             % b0 off-resonance
for i = 1:64
for j = 1:64
    b0(j,i) = -200*exp(-((i-32).^2 + (j-12).^2)/(2*8^2));   % b0 in Hz
end
end
t = repmat(0.5*(1:64)'/1000,1,64);  % t is trajetory timing, in seconds
E = xfm_FFT([64,64,1,1],sens,struct('field',b0,'t',t,'L',20,'idx',1),'mask',mask);

x = phantom(64);

y = E*x;            % Forward Transform
z = E'*y;           % Adjoint Transform
z = E.mtimes2(x);   % equivalent to z = E'Ex

out = E.iter(y,@pcg,1E-4,10);   % un-regularised cgSENSE w/ b0 correction

%% xfm_NUFFT with perturbed spiral trajectory and coil sensitivities
N_k = 64^2;                                         % number of k-samples
t   = linspace(0,sqrt(pi),N_k)';                    % dummy variable to parameterise spiral
k_x = (1 + randn(N_k,1)/20).*t.^2.*cos(2*pi*32*t);  % spiral kx-coords
k_y = (1 + randn(N_k,1)/20).*t.^2.*sin(2*pi*32*t);  % spiral ky-coords
k   = cat(3,k_x,k_y);

load('sens');   % load coil sensitivities
E = xfm_NUFFT([64,64,1,1],sens,[],k,'wi',1);  % no density compensation

x = phantom(64);

y = E*x;            % Forward Transform
z = E'*y;           % Adjoint Transform
z = E.mtimes2(x);   % equivalent to z = E'Ex

out = E.iter(y,@pcg,1E-4,100);   % un-regularised cgSENSE 

%% xfm_NUFFT with random trajectory, coil sensitivities and multiple time points
k = randn(1024,16,2);   % Gaussian density 2D random with 16 time-points

load('sens');   % load coil sensitivities
E = xfm_NUFFT([64,64,1,16],sens,[],k,'wi',1) % no density compensation

x = repmat(phantom(64),1,1,1,16);

y = E*x;            % Forward Transform
z = E'*y;           % Adjoint Transform
z = E.mtimes2(x);   % equivalent to z = E'Ex

out = E.iter(y,@pcg,1E-4,100);   % un-regularised cgSENSE 

%% xfm_DFT
% xfm_DFT usage is almost identical to xfm_NUFFT, except the DFT matrix is 
% explicitly constructed, rather than using the NUFFT
% So it is a drop-in replacement with no external dependencies, but is not 
% memory/computationally efficient. It also omits density compensation,
% which is more SNR efficient anyway
% I wouldn't use this for anything other than medium-sized 2D reconstruction problems
N_k = 64^2;                                         % number of k-samples
t   = linspace(0,sqrt(pi),N_k)';                    % dummy variable to parameterise spiral
k_x = (1 + randn(N_k,1)/20).*t.^2.*cos(2*pi*32*t);  % spiral kx-coords
k_y = (1 + randn(N_k,1)/20).*t.^2.*sin(2*pi*32*t);  % spiral ky-coords
k   = cat(3,k_x,k_y);

load('sens');   % load coil sensitivities
E = xfm_DFT([64,64,1,1],sens,[],k); 

x = phantom(64);

y = E*x;            % Forward Transform
z = E'*y;           % Adjoint Transform
z = E.mtimes2(x);   % equivalent to z = E'Ex

out = E.iter(y,@pcg,1E-4,100);   % un-regularised cgSENSE 

%% xfm_NUFFT with perturbed spiral trajectory and coil sensitivities
N_k = 64^2;                                         % number of k-samples
t   = linspace(0,sqrt(pi),N_k)';                    % dummy variable to parameterise spiral
k_x = (1 + randn(N_k,1)/20).*t.^2.*cos(2*pi*32*t);  % spiral kx-coords
k_y = (1 + randn(N_k,1)/20).*t.^2.*sin(2*pi*32*t);  % spiral ky-coords
k   = cat(3,k_x,k_y);

% load('sens');   % load coil sensitivities
E = xfm_NUFFT([64,64,1,1],[],[],k,'wi',1);  % no density compensation

x = phantom(64);

y = E*x;            % Forward Transform
z = E'*y;           % Adjoint Transform
z = E.mtimes2(x);   % equivalent to z = E'Ex

out = E.iter(y,@pcg,1E-4,100);   % un-regularised cgSENSE 
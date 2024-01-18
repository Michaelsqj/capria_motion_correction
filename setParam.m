%% define basic parameters
% System
p.gamma                         = 4.258;                % [1/G/ms]
p.gfact                         = 2;                        % factor to limit the gradient and slew rate             
p.gmax                          = 2.328/p.gfact;                        % G/cm
p.smax                          = 12.307/p.gfact;                       % G/cm/ms

p.T                             = 10e-3;                        % gradient raster time

% Design Parameters
p.bwpixel                       = 100;                      % Hz, bandwidth per pixel
p.mat                           = 176;              % matrix size
p.fov                           = 200;                      % mm
p.res                           = p.fov / p.mat;                % mm
p.kmax                          = 5 / p.res;                  % [1/cm]

p.OS                            = 8;                        % oversampling factor
p.bw_readout                    = p.bwpixel * p.mat;                  % Hz
p.Ts                            = 1e3 / p.bw_readout / p.OS;               % ms, ADC sampling time
p.NCols                         = p.mat * p.OS;
p.readout_time                  = p.NCols * p.Ts;                           % ms
p.grad_time                     = ceil(p.readout_time / p.T) * p.T;
p.dead_ADC_pts                  = 10;            % dead ADC points before the actual gradient
p.dead_time                     = p.T * ceil(p.dead_ADC_pts * p.Ts / p.T);
p.dead_pts                      = ceil(p.dead_ADC_pts * p.Ts / p.T);

% Sequence parameters
p.Nt                            = 49;            % for simplicity, only simulate 1 phase here
p.NLines                        = 36*6;

p.cone_angle                    = 60;
p.cone_type                     = 'radial';
p.GRtype                        = 2;    % 1: bit reverse GR, 2: full sphere GR

p.kspace_cutoff                 = 1/3;


p.phantom_name                  = '/vols/Data/okell/qijia/moco_5-5-23/meas_MID00111_FID13940_to_CV_VEPCASL_v0p6_qijia_36x49_176_164Hz_vFA_mean_gridding_ref.nii.gz';
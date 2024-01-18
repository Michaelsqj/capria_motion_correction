function [kA] = calc_ADCpts(k, T, Ts, LEN)
    %-----------------------------------------
    % linear interpolate the gradient raster points to generate ADC sampling points
    % Inputs:
    %   g: gradient array [Nx3]
    %   T: gradient raster time, (ms)
    %   Ts: ADC sampling points, (ms)
    %   LEN: readout length
    gamma = 42.58e2;   % Hz/G
    N = size(k, 1);
    grad_points = (0: (N-1)) .* T;
    read_points = (0: (LEN-1)) .* Ts;
    
    kA(:,1) = interp1(grad_points, k(:,1), read_points, 'linear', 'extrap');
    kA(:,2) = interp1(grad_points, k(:,2), read_points, 'linear', 'extrap');
    kA(:,3) = interp1(grad_points, k(:,3), read_points, 'linear', 'extrap');

end
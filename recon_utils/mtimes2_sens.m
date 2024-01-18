function [x_out] = mtimes2_sens(Es, x)
    % x: Nx, Ny, Nz, Nt
    % Es: Nshots of E

    x_out = zeros(size(x));
    tic
    Nshots = length(Es);
    for ii = 1:Nshots
        E = Es(ii);
        x_out = x_out + E.mtimes2(x);
    end
    t=toc; fprintf('mtimes2_sens: %f s\n', t);
end
function step = max_step_sens(Es,iters)
    if nargin < 2
        iters = inf;
    end
    %   Use the power method to find the max eigenvalue of E'E
    E   =   Es(1);
    y   =   randn(E.msize);
    N   =   0;
    ii  =   0;
    while abs(norm(y(:)) - N)/N > 1E-4 && ii < iters
        N   =   norm(y(:)); 
        fprintf('Iteration %d: %f\n', ii, N);
        if nargout == 0
            disp(1./N);
        end
        % y   =   xfm.mtimes2(y/N);
        y   =   mtimes2_sens(Es, y/N);
        ii  =   ii+1;
    end
    step    =   1./norm(y(:));
end
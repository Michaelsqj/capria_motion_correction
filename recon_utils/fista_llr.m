function [x1] = fista_llr(E, dd, lambda, patch_size, im_size, niter)
    x0 = zeros(size(dd));
    x1 = zeros(size(dd));

    L   =   1/E.max_step(10);
    tk  =   1/L;

    for ii = 1:niter
        tic
        y = x1 + (ii-2)/(ii+1)*(x1-x0);
        x0 = x1;
        y = y - tk*(E.mtimes2(y)-dd);
        x1 = prox_llr(y, lambda, im_size, patch_size);
        t0 = toc;
        disp(['Iteration ', num2str(ii), ' done in ', num2str(t0),' seconds.'])
    end

end
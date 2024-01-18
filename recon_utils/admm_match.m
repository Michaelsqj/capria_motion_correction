function [x] = admm_match(E, dd, lambda, patch_size, im_size, niter, rho_0)
    % ADMM_MISMATCH  Solve for ||PFCx-y||_2^2 + lambda \sum||R_iBx||_*
    %  [x1, x2] = admm_mismatch(E1, dd1, E2, dd2, lambda, patch_size, im_size, niter)
    %  solves for x1 and x2 in the above problem
    %  E1, E2 are the encoding matrices for the two images
    %  kd1, kd2: [npts, nt, nc]
    %  lambda is the regularization parameter
    %  patch_size is the size of the patches
    %  im_size is the size of the image, [sx, sy, sz, nt]
    %  niter is the number of iterations
    %  rho is the augmented Lagrangian parameter
    %    
    % Initialize variables, x1, x2, z, u
    x = zeros(size(dd(:)));
    z = zeros(size(x));
    u = zeros(size(z));
    rho = rho_0;

    for ii = 1:niter
        z_old = z;
        % Update x1, x2
        % Use conjugate gradient to solve for 
        %   [x1,x2] = argmin_x ||E1'E1x1 - dd1||_2^2 +||E'2E2x1 - dd2||_2^2 + rho/2 ||x1 - x2 - z + u||_2^2
        tic
        [x,flag,relres,iter] = pcg(@afun_cg,dd(:)+(rho/2)*(z-u),1e-6,[],[],[]);
        t0=toc;

        % Update z
        % Use soft thresholding to solve for 
        %   z = argmin_z \sum lambda ||R_iz||_* + rho/2 ||z-(Bx+u)||_2^2
        %   z = llr(Bx+u, lambda/rho)
        tic
        z = prox_llr(reshape(x + u, im_size), lambda/rho, im_size, patch_size);
        z = z(:);
        t1=toc;

        % Update u
        %   u = u + Bx - z
        u = u + x - z;

        % adaptive scale rho
        if false
            r = x - z;
            s = rho*(z - z_old);
            rho = rho_scaling(rho_0, sum(r(:).^2), sum(s(:).^2));
        end

        disp(['Iteration ', num2str(ii), ' rho ', num2str(rho),' done in ', num2str(t0),'+', num2str(t1), ' seconds.'])
    end

    x = reshape(x, im_size);

    % function handle for conjugate gradient
    function y=afun_cg(x)
        y = reshape(E.mtimes2(reshape(x, im_size)),[],1) + (rho/2)*x;
    end

end
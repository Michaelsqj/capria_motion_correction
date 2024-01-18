function [x1, x2] = admm_mismatch_sens(E1, dd1, E2, dd2, senses1, senses2, lambda, patch_size, im_size, niter, rho_0, logpath)
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
    rho = rho_0;
    
    % Initialize variables, x1, x2, z, u
    x = zeros(2*prod(im_size),1);
    z = zeros(prod(im_size),1);
    u = zeros(prod(im_size),1);

    for ii = 1:niter
        % Update x1, x2
        % Use conjugate gradient to solve for 
        %   [x1,x2] = argmin_x ||E1'E1x1 - dd1||_2^2 +||E'2E2x1 - dd2||_2^2 + rho/2 ||x1 - x2 - z + u||_2^2
        tic
        [x,flag,relres,iter] = pcg(@afun_cg,[dd1(:)+rho/2*(z(:)-u(:)); dd2(:)-rho/2*(z(:)-u(:))],1e-6,[],[],[]);
        t0=toc;

        % Update z
        % Use soft thresholding to solve for 
        %   z = argmin_z \sum lambda ||R_iz||_* + rho/2 ||z-(Bx+u)||_2^2
        %   z = llr(Bx+u, lambda/rho)
        tic
        z = llr(reshape(x(1:prod(im_size)) - x(prod(im_size)+1:end) + u, im_size), lambda/rho, im_size, patch_size);
        z = z(:);
        t1=toc;

        % Update u
        %   u = u + Bx - z
        u = u + x(1:prod(im_size)) - x(prod(im_size)+1:end) - z;

        disp(['Iteration ', num2str(ii), ' rho ', num2str(rho),' done in ', num2str(t0),'+', num2str(t1), ' seconds.'])
        if mod(ii,20)==1 && ~isempty(logpath)
            rd = reshape(x(1:prod(im_size)) - x(prod(im_size)+1:end), im_size);
            save_avw(abs(rd), [char(logpath), '/admm_mismatch_sens_', num2str(ii)], 'd', [1,1,1]);
        end
    end

    x1 = reshape(x(1:prod(im_size)), im_size);
    x2 = reshape(x(prod(im_size)+1:end), im_size);

    % function handle for conjugate gradient
    function y=afun_cg(x)
        y1 = reshape(mtimes2_sens(E1, reshape(x(1:prod(im_size)), im_size), senses1),[],1) + rho/2*(x(1:prod(im_size))-x(prod(im_size)+1:end));
        y2 = reshape(mtimes2_sens(E2, reshape(x(prod(im_size)+1:end), im_size), senses2),[],1) - rho/2*(x(1:prod(im_size))-x(prod(im_size)+1:end));
        y = [y1; y2];
    end

end


function z = llr(x, lambda, im_size, p)
    % LLR  Soft thresholding
    % p is the patch size
    z = x;
    [ii,jj,kk]  =   meshgrid(randperm(p(1),1)-(p(1)-1)/2:p(1):im_size(1),randperm(p(2),1)-(p(2)-1)/2:p(2):im_size(2),randperm(p(3),1)-(p(3)-1)/2:p(3):im_size(3));
   
    for idx = 1:length(ii(:))
        q   =   get_patch(x, ii(idx), jj(idx), kk(idx), p);
        [u,s,v]     =   svd(reshape(q,[],im_size(4)),'econ');
        s   =   shrink(s, lambda); 
        q   =   reshape(u*s*v', size(q));
        z   =   put_patch(z, q, ii(idx), jj(idx), kk(idx), p);
    end
    
end

function q = get_patch(X, i, j, k, p)

    [sx,sy,sz,st]   =   size(X);
    q               =   X(max(i-(p(1)-1)/2,1):min(i+(p(1)-1)/2,sx),max(j-(p(2)-1)/2,1):min(j+(p(2)-1)/2,sy), max(k-(p(3)-1)/2,1):min(k+(p(3)-1)/2,sz),:);
    
end

function X = put_patch(X, q, i, j, k, p)
    [sx,sy,sz,st]   =   size(X);
    X(max(i-(p(1)-1)/2,1):min(i+(p(1)-1)/2,sx),max(j-(p(2)-1)/2,1):min(j+(p(2)-1)/2,sy), max(k-(p(3)-1)/2,1):min(k+(p(3)-1)/2,sz),:) = q;
end

function y = shrink(x, thresh)
    y = diag(max(diag(x)-thresh,0));
end
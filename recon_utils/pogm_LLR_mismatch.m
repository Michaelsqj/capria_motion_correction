function [x1, x2] = pogm_LLR_mismatch(E1, dd1, E2, dd2, lambda, patch_size, im_size, niter)

%   Mark Chiew  
%   May 2021
%
%   Locally-low-rank constrained reconstruction using POGM
%   (p1306, Taylor et al., 2017)

%   Initialise
    x1   =   zeros(im_size);
    y1   =   zeros(im_size);
    z1   =   zeros(im_size);
    y01  =   zeros(im_size);
    
    dd1  =   reshape(dd1, im_size);
%-------------------------------------
    x2   =   zeros(im_size);
    y2   =   zeros(im_size);
    z2   =   zeros(im_size);
    y02  =   zeros(im_size);
    
    dd2  =   reshape(dd2, im_size);


    p   =   patch_size;
    L   =   1/max_step(E1, E2, 10);
    % L   =   3.0358e-10;

    a   =   1;  % theta in algorithm
    b   =   1;  % gamma in algorithm

%   Main loop
fprintf(1, '%-5s %-16s\n', 'Iter','Cost');
for iter = 1:niter

    %   y-update
    y01  =   y1;
    y02  =   y2;

    tic
    y1   =   x1 - (1/L)*(E1.mtimes2(x1)-dd1);
    y2   =   x2 - (1/L)*(E2.mtimes2(x2)-dd2);

    %   a-update (theta)
    a0  =   a;
    if iter < niter
        a = (1+sqrt(4*a^2+1))/2;
    else
        a = (1+sqrt(8*a^2+1))/2;
    end

    %   z-update
    z1   =   y1 + ((a0-1)/a)*(y1-y01) + (a0/a)*(y1-x1) + ((a0-1)/(L*b*a))*(z1 - x1);
    z2   =   y2 + ((a0-1)/a)*(y2-y02) + (a0/a)*(y2-x2) + ((a0-1)/(L*b*a))*(z2 - x2);

    %   b-update (gamma)
    b0  =   b;
    b   =   (2*a0+a-1)/(L*a);

    t1 = toc;
    tic
    %   x-update
    [ii,jj,kk]  =   meshgrid(randperm(p(1),1)-(p(1)-1)/2:p(1):im_size(1),randperm(p(2),1)-(p(2)-1)/2:p(2):im_size(2),randperm(p(3),1)-(p(3)-1)/2:p(3):im_size(3));

    z_sub = (z1-z2)/2;
    x_avg = (x1+x2)/2;
    x_sub = (x1-x2)/2;
    for idx = 1:length(ii(:))
        % fprintf(1, '%d ', idx); drawnow('update');
        q   =   get_patch(z_sub, ii(idx), jj(idx), kk(idx), p);
        [u,s,v]     =   svd(reshape(q,[],im_size(4)),'econ');
        s   =   shrink(s, lambda*b); 
        q   =   reshape(u*s*v', size(q));
        x_sub   =   put_patch(x_sub, q, ii(idx), jj(idx), kk(idx), p);
    end
    x1  =   x_avg + x_sub;
    x2  =   x_avg - x_sub;
    
    t2 = toc;
    %   Display iteration number and t1 t2 time spent
    fprintf(1, '%-5d iter, mtimes2: %-16.4f s, llr: %-16.4f s, total: %-16.4f s \n', iter, t1, t2, t1+t2);
    % fprintf(1, '%-5d -\n', iter);
    % fprintf(1, '')
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

function [step] = max_step(E1, E2, iters)
    y1 = randn(E1.msize);
    y2 = randn(E2.msize);

    y = [y1; y2];

    N = 0;
    ii= 0;

    while abs(norm(y(:)) - N)/N > 1e-4 && ii<iters
        N = norm(y(:));
        disp(1./N);
        y1 = E1.mtimes2(y1/N);
        y2 = E2.mtimes2(y2/N);
        y = [y1; y2];
        ii = ii+1;
    end
    step  = 1./norm(y(:));
end
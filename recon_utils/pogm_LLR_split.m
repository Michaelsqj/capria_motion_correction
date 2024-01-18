function [x_1, x_2] = pogm_LLR_split(E_1, dd_1, E_2, dd_2, lambda, patch_size, im_size, niter)

%   Mark Chiew  
%   May 2021
%
%   Locally-low-rank constrained reconstruction using POGM
%   (p1306, Taylor et al., 2017)

%   Initialise
    x_1   =   zeros(im_size);
    y_1   =   zeros(im_size);
    z_1   =   zeros(im_size);
    y0_1  =   zeros(im_size);
    
    dd_1  =   reshape(dd_1, im_size);

    p   =   patch_size;
    L_1   =   1/E_1.max_step(10);

    a_1   =   1;  % theta in algorithm
    b_1   =   1;  % gamma in algorithm

    %%%%
    x_2   =   zeros(im_size);
    y_2   =   zeros(im_size);
    z_2   =   zeros(im_size);
    y0_2  =   zeros(im_size);
    
    dd_2  =   reshape(dd_2, im_size);

    p   =   patch_size;
    L_2   =   1/E_2.max_step(10);

    a_2   =   1;  % theta in algorithm
    b_2   =   1;  % gamma in algorithm

    L_1   =  min(L_1, L_2);
    L_2   =  L_1;

%   Main loop
fprintf(1, '%-5s %-16s\n', 'Iter','Cost');
for iter = 1:niter

    %% update 1

    %   y-update
    y0_1  =   y_1;
    y_1   =   x_1 - (1/L_1)*(E_1.mtimes2(x_1)-dd_1);

    %   a-update (theta)
    a0_1  =   a_1;
    if iter < niter
        a_1 = (1+sqrt(4*a_1^2+1))/2;
    else
        a_1 = (1+sqrt(8*a_1^2+1))/2;
    end

    %   z-update
    z_1   =   y_1 + ((a0_1-1)/a_1)*(y_1-y0_1) + (a0_1/a_1)*(y_1-x_1) + ((a0_1-1)/(L_1*b_1*a_1))*(z_1 - x_1);

    %   b-update (gamma)
    b0_1  =   b_1;
    b_1   =   (2*a0_1+a_1-1)/(L_1*a_1);

    % tmpz  = zeros(size(x_1));
    %   x-update
    [ii,jj,kk]  =   meshgrid(randperm(p(1),1)-(p(1)-1)/2:p(1):im_size(1),randperm(p(2),1)-(p(2)-1)/2:p(2):im_size(2),randperm(p(3),1)-(p(3)-1)/2:p(3):im_size(3));
   
    tmp = z_1 - x_2;
    for idx = 1:length(ii(:))
        q   =   get_patch(tmp, ii(idx), jj(idx), kk(idx), p);
        [u,s,v]     =   svd(reshape(q,[],im_size(4)),'econ');
        s   =   shrink(s, lambda*b_1); 
        q   =   reshape(u*s*v', size(q));
        tmp   =   put_patch(tmp, q, ii(idx), jj(idx), kk(idx), p);
    end
    x_1 = x_2 + tmp;

    %% update 2

    %   y-update
    y0_2  =   y_2;
    y_2   =   x_2 - (1/L_2)*(E_2.mtimes2(x_2)-dd_2);

    %   a-update (theta)
    a0_2  =   a_2;
    if iter < niter
        a_2 = (1+sqrt(4*a_2^2+1))/2;
    else
        a_2 = (1+sqrt(8*a_2^2+1))/2;
    end

    %   z-update
    z_2   =   y_2 + ((a0_2-1)/a_2)*(y_2-y0_2) + (a0_2/a_2)*(y_2-x_2) + ((a0_2-1)/(L_2*b_2*a_2))*(z_2 - x_2);

    %   b-update (gamma)
    b0_2  =   b_2;
    b_2   =   (2*a0_2+a_2-1)/(L_2*a_2);

    %   x-update
    % [ii,jj,kk]  =   meshgrid(randperm(p(1),1)-(p(1)-1)/2:p(1):im_size(1),randperm(p(2),1)-(p(2)-1)/2:p(2):im_size(2),randperm(p(3),1)-(p(3)-1)/2:p(3):im_size(3));
    % tmpz  = zeros(size(x_1));
    tmp = z_2 - x_1;
    for idx = 1:length(ii(:))
        q   =   get_patch(tmp, ii(idx), jj(idx), kk(idx), p);
        [u,s,v]     =   svd(reshape(q,[],im_size(4)),'econ');
        s   =   shrink(s, lambda*b_2); 
        q   =   reshape(u*s*v', size(q));
        tmp   =  put_patch(tmp, q, ii(idx), jj(idx), kk(idx), p);
    end
    x_2 = x_1 + tmp;



    %   Display iteration summary data
    fprintf(1, '%-5d -\n', iter);
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

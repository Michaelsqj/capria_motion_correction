function z = prox_llr(x, lambda, im_size, p)
    % proximal operator for LLR  Soft thresholding of singular values
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
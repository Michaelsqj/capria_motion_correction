[img, ~, scales, ~, ~] = read_avw('/home/fs0/qijia/scratch/moco_exp/expout/subspace_25-10-23/rd_61.nii.gz');
img = img*1e10;
im_size = size(img);
s1 = 25; s2 = 30; s3 = 0;
p=[5,5,5];
lambda = 100;
b = 1;
[ii,jj,kk]  =   meshgrid(s1-(p(1)-1)/2:p(1):im_size(1), s2-(p(2)-1)/2:p(2):im_size(2), s3-(p(3)-1)/2:p(3):im_size(3));

x = zeros(size(img));

for idx = 1:length(ii(:))
    q   =   get_patch(img, ii(idx), jj(idx), kk(idx), p);
    [u,s,v]     =   svd(reshape(q,[],im_size(4)),'econ');
    s   =   shrink(s, lambda*b); 
    q   =   reshape(u*s*v', size(q));
    x   =   put_patch(x, q, ii(idx), jj(idx), kk(idx), p);
end

save_avw(x, '/home/fs0/qijia/scratch/moco_exp/expout/subspace_25-10-23/rd_61_llr_matlab.nii.gz', 'd', scales);


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
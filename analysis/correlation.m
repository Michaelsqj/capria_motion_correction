function [r, r_all] = correlation(img1_fpath, img2_fpath, mask_fpath, write_fpath)
    % calculate correlation between two images
    % use brain mask for perfusion and structural 
    % use vessel mask for angiogram
    wd=cd('/home/fs0/qijia/code/moco')
    include_path;
    cd(wd)
    img1 = niftiread(img1_fpath);
    img2 = niftiread(img2_fpath);
    mask = niftiread(mask_fpath);
    % img1 = img;
    % [img,~,scales,~,~] = read_avw(img2_fpath);
    % img2 = img;
    % [mask,~,scales,~,~] = read_avw(mask_fpath);
    mask = logical(mask);
    for ii=1:size(img2,4)
        i1=img1(:,:,:,ii);
        i2=img2(:,:,:,ii);
        tmp = corrcoef(i1(mask), i2(mask));
        r(ii) = tmp(1,2);
    end
    i1_all=reshape(img1,[],size(img1,4));
    i1_all=i1_all(mask(:),:);
    i2_all=reshape(img2,[],size(img2,4));
    i2_all=i2_all(mask(:),:);
    tmp = corrcoef(i1_all(:), i2_all(:));
    r_all = tmp(1,2);
    if nargin==4 && write_fpath ~= []
        % write r array to text file with write_fpath
        fid = fopen(write_fpath,'w');
        for ii=1:length(r)
            fprintf(fid,'%f ',r(ii));
        end
        fclose(fid);
    end
end
function r = correlation(img1_fpath, img2_fpath, mask_fpath, write_fpath)
    % calculate correlation between two images
    % use brain mask for perfusion and structural 
    % use vessel mask for angiogram
    cd .. 
    include_path;
    [img,~,scales,~,~] = read_avw(img1_fpath);
    img1 = img;
    [img,~,scales,~,~] = read_avw(img2_fpath);
    img2 = img;
    [mask,~,scales,~,~] = read_avw(mask_fpath);
    mask = logical(mask);
    for ii=1:size(img2,4)
        i1=img1(:,:,:,ii);
        i2=img2(:,:,:,ii);
        tmp = corrcoef(i1(mask), i2(mask));
        r(ii) = tmp(1,2);
    end
    if nargin==4
        % write r array to text file with write_fpath
        fid = fopen(write_fpath,'w');
        for ii=1:length(r)
            fprintf(fid,'%f ',r(ii));
        end
        fclose(fid);
    end
end
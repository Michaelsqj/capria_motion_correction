function process_sens_mask(fpath)
    [img,~,scales,~,~] = read_avw(fpath);
    % binarize the sensitivity map
    img = logical(img ~= 0);
    % crop out top and bottom 1 row
    img(:,:,1) = 0;
    img(:,:,end) = 0;
    % save
    save_avw(logical(img),[fpath '_mask'],'b',scales);
end
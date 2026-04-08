function gen_masks(imsize, n_masks, outpath)
    mkdir(outpath)
    mask_size = floor(prod(imsize) / n_masks);
    
    for i = 1:n_masks
        mask = zeros(prod(imsize), 1);
        mask(((i-1)*mask_size+1):min(i*mask_size, prod(imsize))) = 1;
        mask = reshape(mask, imsize);
        save_avw(logical(mask), [outpath '/mask_' num2str(i)], 'b', [1,1,1])
        fprintf(['mask_' num2str(i) '.nii.gz'])
    end
end
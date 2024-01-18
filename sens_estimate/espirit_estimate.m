function espirit_estimate(ind)
% Set parameters
    cd ..
    include_path();
    cd sens_estimate
    load('/vols/Data/okell/qijia/perf_recon_12-10-23/mprage_t1','ksp2')
    DATA = ifftc(ksp2,1);
    kB0 = squeeze(ksp2(ind,:,:,:));
    %%
    [nx,ny,nc]=size(kB0);
    ksize = [5,5];
    eigThresh_1 = 0.02;
    eigThresh_2 = 0.95;
    calib = crop(kB0,[48,48,nc]);
    [k,S] = dat2Kernel(calib,ksize);
    idx = max(find(S >= S(1)*eigThresh_1));
    [M,W] = kernelEig(k(:,:,:,1:idx),[nx,ny]);
    Sensitivity_map_raw(:,:,:) = M(:,:,:,end).*repmat(W(:,:,end)>eigThresh_2,[1,1,nc]);
    sens = Sensitivity_map_raw;
    save(['/vols/Data/okell/qijia/perf_recon_12-10-23/mprage_sens/sens_' num2str(ind)], 'sens');
end
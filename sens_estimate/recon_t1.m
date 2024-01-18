function recon_t1(date)
    listing = dir(['/vols/Data/okell/qijia/raw_data_' char(date) '/*PSN.dat'])
    measID= ['/vols/Data/okell/qijia/raw_data_' char(date) '/' listing(1).name(1:end-4)]
    save_file = ['/vols/Data/okell/qijia/raw_data_' char(date) '/' listing(1).name(1:end-4)]
    twix_obj = mapVBVD(measID,'ignoreSeg',true,'removeOS',false);
    image=twix_obj{end}.image(:,:,:,:);
    [sx, nc, sy, sz] = size(image)
    %% x, c, y, z
    pad_image=zeros(256,nc,sy,sz);
    pad_image(end-sx+1:end,:,:,:)=image;
    pad_image_ifft=bart('fft -i 1',pad_image);
    crop_image=bart('fft 1',pad_image_ifft(65:(65+127),:,:,:));
    crop_image=permute(crop_image,[1,3,4,2]);
    NCoils=size(crop_image,4);
    [~, xfm, ~] = calc_psens(reshape(crop_image,[],NCoils));
    Nc = 8;
    cs_image = apply_sens_xfm(xfm, reshape(crop_image, [], NCoils), Nc, 2);
    cs_image = reshape(cs_image, [size(crop_image,1:3), Nc]);
    tmp=bart('fft -i 7', cs_image);
    tmp=permute(tmp,[2,1,3,4]);
    cs_rd=tmp(:,end:-1:1,end:-1:1,:);
    cs_rd_rss = bart('rss 8', cs_rd);
    q=matfile([save_file '_anat.mat'],'Writable',true);
    q.m=cs_rd;
    q.anat=cs_rd_rss;
    save_avw(cs_rd_rss,[save_file '_anat'],'d',[220/128, 220/128, 1.7]);
    save([save_file '_compress'],'xfm','Nc');
end
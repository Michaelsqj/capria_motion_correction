function combine_shots(basename, outname)
    for i = 1:98
        filename = [char(basename) '_' num2str(i) '.nii.gz'];
        if i == 1
            [img,~,scales,~,~]=read_avw(filename);
            imgs = zeros([size(img) 98]);
            imgs(:,:,:,1) = img;
        else
            [img2,~,scales,~,~]=read_avw(filename);
            imgs(:,:,:,i) = img2;
        end
    end
    % nt = size(img,4);
    save_avw(imgs, outname, 'd', scales);
end
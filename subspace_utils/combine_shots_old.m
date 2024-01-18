function combine_shots_old(dirname, outname)
    listings = dir([char(dirname),'/*.nii.gz']);
    for i = 1:length(listings)
        filename = [char(dirname),'/',listings(i).name];
        if i == 1
            [img,~,scales,~,~]=read_avw(filename);
        else
            [img2,~,scales,~,~]=read_avw(filename);
            img = img + img2;
        end
    end
    nt = size(img,4);
    save_avw(img(:,:,:,1:nt/2), outname, 'd', scales);
end
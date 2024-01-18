function flip_img(infile, outfile)
    cd ..
    include_path()
    [img,~,scales,~,~]=read_avw(char(infile));
    save_avw(img(end:-1:1,end:-1:1,:),char(outfile),'d',scales);
end
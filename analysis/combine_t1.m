function combine_t1(fpath, outpath)
    addpath('/home/fs0/qijia/code/moco/')
    include_path()
    fs=["M0" "InvAlpha" "T1" "B1rel"]
    for f = fs
        for ii = 1:1000
            [img,~,scales,~,~] = read_avw([char(fpath) '/' char(f) '_'  num2str(ii)]);
            if ii == 1
                img_out = img;
            else
                img_out = img_out + img;
            end
        end
        save_avw(img_out, [char(outpath) '/' char(f)], 'd', scales);
    end

end
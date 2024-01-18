function adjust_thresh(fpath, thresh, res)
    % mprage_t1_res = [1.718750,1.718750,1.7];
    % perfusion res  = [3.409100,3.409100,3.409100];
    if isempty(thresh)
        thresh = 0.037;
    end
    if isempty(res)
        res = [1.718750,1.718750,1.7];
    end
    addpath('/home/fs0/qijia/code/SimTraj/MChiewCAPRIARecon/')
    [dirname sensname ext] = fileparts(fpath);
    anatname = strrep(sensname, 'sens','anat')
    anatfile=[dirname '/' anatname]
    sensfile=[dirname '/' sensname]
    senspath=[dirname '/' anatname '.' sensname]
    q=matfile(anatfile);
    combine_sens(sensfile,0,senspath,permute(squeeze(q.m),[4,1,2,3]),thresh);
    [img,~,scales,~,~]=read_avw(sensfile);
    save_avw(img,sensfile,'d',res);
    % save_avw(img,sensfile,'d',[1 1 1]*3.409100);
    rmpath('/home/fs0/qijia/code/SimTraj/MChiewCAPRIARecon/')
end
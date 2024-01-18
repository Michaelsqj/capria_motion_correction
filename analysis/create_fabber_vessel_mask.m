function create_fabber_vessel_mask(fpath, p)
    % Generate a mask for the angio fitting
    % fpath: path to the angio file
    % p: parameters
    %   thresh1: around 30 to 60
    %   thresh2: 0.1 to upper
    %   thresh3: 2 or 0(default)
    % 1. preprocess data
    if nargin<2
        p.thresh1 = 30;
        p.thresh2 = 0.1;
        p.thresh3 = 2;
    end
    [dirname,name,ext] = fileparts(fpath)
    name = char(name);
    name = name(1:end-length('.nii'));
    ext = ".nii.gz";
    fname = name + ext
    outpath = char(name+"_AngioFitting")
    mkdir([char(dirname) '/' char(outpath)])
    cd([char(dirname) '/' char(outpath)])

    % 1.1 Rescale the data to prevent premature fitting stops
    if ~isfile('data.nii.gz')
        tosystem(['fslmaths ../', char(fname), ' -mul 1e10 data'])
    end
    
    % 1.2 Generate a mask
    if isfield(p, 'thresh1') && p.thresh1 ~= 0
        tosystem(['fslmaths data -Tmax -thr ',ns(p.thresh1),' -bin mask']) % threshold default around 30
    end 
    if isfield(p, 'thresh2') && p.thresh2 ~= 0
        tosystem(['cluster --in=mask --thresh=' ns(p.thresh2) ' -o mask_clusters'])
    end
    
    [~,tmp]=builtin('system','fslstats mask_clusters -R');
    maxI = split(tmp,' ');
    maxI = str2num(maxI{2});
    thr = ns(maxI - 1);
    if isfield(p, 'thresh3') && p.thresh3 ~= 0
        thr = ns(p.thresh3);
    end
    tosystem(['fslmaths mask_clusters -thr ' thr ' -bin mask_clusters_bin'])
end
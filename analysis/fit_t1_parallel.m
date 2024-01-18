function fit_t1_parallel(fname, maskname, outpath, part, is_subspace, prot_type)
    addpath('/home/fs0/qijia/code/moco/')
    addpath('/home/fs0/qijia/code/CAPRIAStaticSignal')
    include_path()
    if nargin < 4
        is_subspace = false;
    end
    if nargin < 5
        prot_type = 2;
    end
    if isempty(maskname)
        maskname=[char(fname) '_brain_mask'];
    end
    if isfile(char(outpath+"/T1_"+num2str(part)))
        return
    end
    % maskname=[char(fname) '_brain_mask'];
    % [Ims, ~, scales,~,~] = read_avw(fname);
    q=matfile([char(fname) '.mat']);
    if is_subspace
        rd = double(q.rd);
        basis = double(q.basis);
        [sx,sy,sz,nk] = size(rd)
        [nt,nk] = size(basis)
        rd = reshape(reshape(rd, sx*sy*sz, nk)*basis', sx,sy,sz,nt);
    else
        rd = double(q.rd);
    end
    printf('size rd: %d %d %d %d\n', size(rd))
    Ims = double(rd);
    [Mask,~,scales,~,~] = read_avw(maskname);
    Mask = logical(Mask);

    n_parts = 1000;
    dims = size(Ims);
    N   =   prod(dims(1:3));
    n   =   ceil(N/n_parts);
    idx =   (part-1)*n+1:min(part*n, N); 
    mask_part = zeros(dims(1:3));
    mask_part(idx) = 1;
    Mask = Mask & reshape(logical(mask_part), dims(1:3));
    %%
    BGSMode='si';

    tau=1.8;
    BGStau1=tau;
    t0 = tau+2e-3+10e-3+11e-3+10e-3+2e-3; 
    T1s = (250:10:4000)*1e-3;
    switch prot_type
        case 0  % cone or radial with matched TR
            TR = 14.7e-3; Nsegs = 12; Nphases = 12; FAParams = [3 12];
        case 1  % radial previous protocol
            TR = 9.8e-3;  Nsegs=18; Nphases = 12; FAParams = [2 9];
        case 2  % water excitation cone
            TR = 16*1e-3;  Nsegs=12; Nphases = 12; FAParams = [3 12];
    end
    FAMode='quadratic';

%     Nsegs = Nphases * Nsegs / dims(4);
%     Nphases = dims(3);
    [M0, InvAlpha, T1, B1rel, fit, Ims_pc] = CAPRIAStaticTissueSignalFit(Ims,Mask,BGSMode,tau,BGStau1,FAMode,FAParams,t0,TR,Nsegs,Nphases);
    save_avw(M0, outpath+"/M0_"+num2str(part),'d',scales);
    save_avw(InvAlpha, outpath+"/InvAlpha_"+num2str(part),'d',scales);
    save_avw(T1, outpath+"/T1_"+num2str(part),'d',scales);
    save_avw(B1rel, outpath+"/B1rel_"+num2str(part),'d',scales);
    % save_avw(fit, outpath+"_fit",'d',scales);
    % save_avw(Ims_pc, outpath+"_Ims_pc",'d',scales);
    include_path(1)
end
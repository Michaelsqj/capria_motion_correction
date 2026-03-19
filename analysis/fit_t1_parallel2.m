function fit_t1_parallel2(fname, outpath, maskname, prot_type, part, n_parts)
    if nargin < 6
        n_parts = 1;
    end
    addpath('/home/fs0/qijia/code/moco/')
    addpath('/home/fs0/qijia/code/CAPRIAStaticSignal')
    include_path()
    if isfile(char(outpath+"/T1_"+num2str(part)))
        return
    end
    % maskname=[char(fname) '_brain_mask'];
    % [Ims, ~, scales,~,~] = read_avw(fname);
    q=matfile([char(fname) '.mat']);
    [Mask,~,scales,~,~] = read_avw(maskname);
    Mask = logical(Mask);
    Ims = double(q.rd) ;
    
    

    % n_parts = 1;
    dims = size(Ims);
    N   =   prod(dims(1:3));
    n   =   ceil(N/n_parts);
    idx =   (part-1)*n+1:min(part*n, N); 
    mask_part = zeros(dims(1:3));
    mask_part(idx) = 1;
    Mask = Mask & reshape(logical(mask_part), dims(1:3));

    Ims = Ims .* Mask;
    if isfield(q, 'basis')
        Ims = reshape(reshape(Ims,prod(size(Ims,1:3)), size(Ims,4))*q.basis', [size(Ims,1:3) size(q.basis,1)]);
    end

    %%
    BGSMode='si';

    tau=1.8;
    BGStau1=tau;
    t0 = tau+2e-3+10e-3+11e-3+10e-3+2e-3; 
    T1s = (250:10:4000)*1e-3;
    FAMode='quadratic';
    switch prot_type
        case 0  % cone or radial with matched TR
            TR = 14.7e-3; Nsegs = 12; Nphases = 12; FAParams = [3 12];
        case 1  % radial previous protocol
            TR = 9.8e-3;  Nsegs=18; Nphases = 12; FAParams = [2 9];
        case 2 % cone cut off on time dimension
            TR = 14.7e-3; Nsegs = 12; Nphases = 7; FAParams = [3 12];
        case 3
            TR = 16e-3; Nsegs = 12; Nphases = 12; FAParams = [3 12];
    end

    
    Nsegs = Nsegs * Nphases / size(Ims,4);
    Nphases = size(Ims,4);
    [M0, InvAlpha, T1, B1rel, fit, Ims_pc] = CAPRIAStaticTissueSignalFit(Ims,Mask,BGSMode,tau,BGStau1,FAMode,FAParams,t0,TR,Nsegs,Nphases);
    save_avw(M0, outpath+"/M0_"+num2str(part),'d',scales);
    % save_avw(InvAlpha, outpath+"/InvAlpha_"+num2str(part),'d',scales);
    save_avw(T1, outpath+"/T1_"+num2str(part),'d',scales);
    % save_avw(B1rel, outpath+"/B1rel_"+num2str(part),'d',scales);
    % save_avw(fit, outpath+"_fit",'d',scales);
    % save_avw(Ims_pc, outpath+"_Ims_pc",'d',scales);
    include_path(1)
end
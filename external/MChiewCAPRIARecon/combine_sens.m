function combine_sens(sens_name, calc_psens,input_dir, mdata, thresh)

    if nargin == 3
        files=dir([input_dir '/tmean_c*.mat']);
        q=load([input_dir '/' files(1).name()]);
        mdata=zeros([length(files),size(q.est)]);
        mdata(1,:,:,:)   =   q.est;
        for n = 2:length(files)
            q   =   load([input_dir '/' files(n).name()]);
            mdata(n,:,:,:)   =   q.est;
        end
    end
    
    if nargin < 5
        thresh = 0.05;
    end
    
    
    files=dir([input_dir '/sens_*.mat']);
    sens=zeros(size(mdata));
    mask=zeros(size(squeeze(sens(1,:,:,:))));
    
    for n = 1:length(files)
        q=load([input_dir '/' files(n).name()]);
        sens(:,q.i)=q.s;
        mask(q.i)=q.m;
    end
    
    sens    =   permute(sens,[2,3,4,1]);
    sens    =   bsxfun(@times, sens,abs(mask)>thresh*max(abs(mask(:))));
    
    save([sens_name '.mat'],'sens','-v7.3');
    addpath('/opt/fmrib/fsl/etc/matlab')
    save_avw(abs(sens), sens_name, 'd', [1,1,1,1]);
dates=["15-11-23" "23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"]
% date="28-11-23"
% dates=["23-11-23" "28-11-23" "29-11-23" "30-11-23" "1-12-23" "1-12-23_2" "7-12-23"];
% static_ind=3;
% dates=["15-11-23"]
% static_ind=4;
% ind=1


%%%%%%%%% Perfusion %%%%%%%%%
%%
r1s=zeros(6,length(dates));
r2s=zeros(6,length(dates));
r3s=zeros(6,length(dates));
ii=1;
for date = dates
    if date=="15-11-23"
        static_ind=4;
        inds=[1,3];
    else
        static_ind=3;
        inds=[1,2];
    end
    for ind=inds
        % perf_recon_path="/vols/Data/okell/qijia/perf_recon_${date}"
        perf_recon_path=['/vols/Data/okell/qijia/perf_recon_' char(date)]
        % 1. calcualte perfusion before correction and with static ind stage3
        img1_fpath=[perf_recon_path '/scan_' num2str(ind) '/perfusion_gt.nii.gz']
        img2_fpath=[perf_recon_path '/scan_' num2str(static_ind) '/perfusion_stage3.nii.gz']
        mask_fpath=[perf_recon_path '/scan_' num2str(static_ind) '/anat2_brain_mask.nii.gz']

        if isfile(img1_fpath) && isfile(img2_fpath) && isfile(mask_fpath)
            [r1s(:,ii), r1s_all(ii)] = correlation(img1_fpath, img2_fpath, mask_fpath);
        end

        % 2. calcualte perfusion after correction and with static ind stage3
        img1_fpath=[perf_recon_path '/scan_' num2str(ind) '/perfusion_stage3.nii.gz']
        img2_fpath=[perf_recon_path '/scan_' num2str(static_ind) '/perfusion_stage3.nii.gz']
        mask_fpath=[perf_recon_path '/scan_' num2str(static_ind) '/anat2_brain_mask.nii.gz']

        if isfile(img1_fpath) && isfile(img2_fpath) && isfile(mask_fpath)
            [r2s(:,ii), r2s_all(ii)] = correlation(img1_fpath, img2_fpath, mask_fpath);
        end

        % 3. calculate perfusion after gridding nav correction with static and stage3
        img1_fpath=[perf_recon_path '/scan_' num2str(ind) '/perfusion_stage1_gridding.nii.gz']
        img2_fpath=[perf_recon_path '/scan_' num2str(static_ind) '/perfusion_stage3.nii.gz']
        mask_fpath=[perf_recon_path '/scan_' num2str(static_ind) '/anat2_brain_mask.nii.gz']

        if isfile(img1_fpath) && isfile(img2_fpath) && isfile(mask_fpath)
            [r3s(:,ii), r3s_all(ii)] = correlation(img1_fpath, img2_fpath, mask_fpath);
        end
        ii=ii+1;
    end
end
save('perfusion_corr.mat','r1s','r2s','r3s','r1s_all','r2s_all','r3s_all')


%%%%%%%%% angio %%%%%%%%%
%%
r1s=zeros(12,length(dates));
r2s=zeros(12,length(dates));
r3s=zeros(12,length(dates));

ii=1;
for date = dates
    if date=="15-11-23"
        static_ind=4;
        inds=[1,3];
    else
        static_ind=3;
        inds=[1,2];
    end
    for ind=inds
        % angio_recon_path="/vols/Data/okell/qijia/recon_${date}"
        angio_recon_path=['/vols/Data/okell/qijia/recon_' char(date)]
        % 1. calcualte angio before correction and with static ind stage3
        img1_fpath=[angio_recon_path '/scan_' num2str(ind) '/angio_gt.nii.gz']
        img2_fpath=[angio_recon_path '/scan_' num2str(static_ind) '/angio_stage3.nii.gz']
        mask_fpath=[angio_recon_path '/scan_' num2str(static_ind) '/angio_gt_dil_vessel_mask.nii.gz']

        if isfile(img1_fpath) && isfile(img2_fpath) && isfile(mask_fpath)
            [r1s(:,ii), r1s_all(ii)] = correlation(img1_fpath, img2_fpath, mask_fpath);
        end

        % 2. calcualte angio after correction and with static ind stage3
        img1_fpath=[angio_recon_path '/scan_' num2str(ind) '/angio_stage3.nii.gz']
        img2_fpath=[angio_recon_path '/scan_' num2str(static_ind) '/angio_stage3.nii.gz']
        mask_fpath=[angio_recon_path '/scan_' num2str(static_ind) '/angio_gt_dil_vessel_mask.nii.gz']

        if isfile(img1_fpath) && isfile(img2_fpath) && isfile(mask_fpath)
            [r2s(:,ii), r2s_all(ii)] = correlation(img1_fpath, img2_fpath, mask_fpath);
        end

        % 3. calcualte angio after gridding nav correction and with static ind stage3
        img1_fpath=[angio_recon_path '/scan_' num2str(ind) '/angio_stage3_gridding.nii.gz']
        img2_fpath=[angio_recon_path '/scan_' num2str(static_ind) '/angio_stage3.nii.gz']
        mask_fpath=[angio_recon_path '/scan_' num2str(static_ind) '/angio_gt_dil_vessel_mask.nii.gz']

        if isfile(img1_fpath) && isfile(img2_fpath) && isfile(mask_fpath)
            [r3s(:,ii), r3s_all(ii)] = correlation(img1_fpath, img2_fpath, mask_fpath);
        end
        ii=ii+1;
    end
end
save('angio_corr.mat','r1s','r2s','r3s','r1s_all','r2s_all','r3s_all')


%%%%%%%%% structural %%%%%%%%%
%%
r1s=zeros(1,length(dates));
r2s=zeros(1,length(dates));
r3s=zeros(1,length(dates));
ii=1;
for date = dates
    if date=="15-11-23"
        static_ind=4;
        inds=[1,3];
    else
        static_ind=3;
        inds=[1,2];
    end
    for ind=inds
        % recon_path="/vols/Data/okell/qijia/recon_${date}"
        recon_path=['/vols/Data/okell/qijia/recon_' char(date)];
        % 1. calcualte structural before correction and with static ind stage3
        img1_fpath=[recon_path '/scan_' num2str(ind) '/struct_gt_frame62.nii.gz'];
        img2_fpath=[recon_path '/scan_' num2str(static_ind) '/struct_stage3_frame62.nii'];
        mask_fpath=[recon_path '/scan_' num2str(static_ind) '/anat2_brain_mask.nii.gz'];

        if isfile(img1_fpath) && isfile(img2_fpath) && isfile(mask_fpath)
            [r1s(:,ii), r1s_all(ii)] = correlation(img1_fpath, img2_fpath, mask_fpath);
        end

        % 2. calcualte structural after correction and with static ind stage3
        img1_fpath=[recon_path '/scan_' num2str(ind) '/struct_stage3_frame62.nii'];
        img2_fpath=[recon_path '/scan_' num2str(static_ind) '/struct_stage3_frame62.nii'];
        mask_fpath=[recon_path '/scan_' num2str(static_ind) '/anat2_brain_mask.nii.gz'];

        if isfile(img1_fpath) && isfile(img2_fpath) && isfile(mask_fpath)
            [r2s(:,ii), r2s_all(ii)] = correlation(img1_fpath, img2_fpath, mask_fpath);
        end

        % 3. calculate structural after gridding nav correction with static and stage3
        img1_fpath=[recon_path '/scan_' num2str(ind) '/struct_stage3_gridding_frame62.nii.gz'];
        img2_fpath=[recon_path '/scan_' num2str(static_ind) '/struct_stage3_frame62.nii'];
        mask_fpath=[recon_path '/scan_' num2str(static_ind) '/anat2_brain_mask.nii.gz'];

        if isfile(img1_fpath) && isfile(img2_fpath) && isfile(mask_fpath)
            [r3s(:,ii), r3s_all(ii)] = correlation(img1_fpath, img2_fpath, mask_fpath);
        end
        ii=ii+1;
    end
end
save('struct_corr.mat','r1s','r2s','r3s','r1s_all','r2s_all','r3s_all')

dt_capria={};
dt_subspace={};
p_capria={};
p_subspace={};
s_capria={};
s_subspace={};
ii=1;
for date=["1-12-22" "9-2-23" "13-2-23" "15-2-23" "17-2-23" "22-11-22"] 
    rootdir=['/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_' char(date) '/'];
    fpath1=['/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_' char(date) '/meas_cone_144_capria_12_lambda0.1_AngioFitting/fabber_out/'];
    fpath2=['/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_' char(date) '/meas_cone_144_subspace_Nt144_Nk12_randomdict_L_balance_0_lambda_0.0005_AngioFitting/fabber_out/'];
    mask_path=[rootdir 'mask_clusters_bin.nii.gz'];
    [img,~,scales,~,~]=read_avw(mask_path);
    mask = logical(img);
    
    [img,~,scales,~,~]=read_avw([fpath1 'mean_deltblood.nii.gz']);
    dt_capria{ii} = img(mask);
    [img,~,scales,~,~]=read_avw([fpath2 'mean_deltblood.nii.gz']);
    dt_subspace{ii} = img(mask);
    
    [img,~,scales,~,~]=read_avw([fpath1 'mean_disp_p.nii.gz']);
    p_capria{ii} = img(mask);
    [img,~,scales,~,~]=read_avw([fpath2 'mean_disp_p.nii.gz']);
    p_subspace{ii} = img(mask);
    
    [img,~,scales,~,~]=read_avw([fpath1 'mean_disp_s.nii.gz']);
    s_capria{ii} = img(mask);
    [img,~,scales,~,~]=read_avw([fpath2 'mean_disp_s.nii.gz']);
    s_subspace{ii} = img(mask);
    
    ii=ii+1;
end


%%
rootdir='/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/';
fpath1='/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/meas_cone_144_capria_12_AngioFitting/fabber_out/';
fpath2='/vols/Data/okell/qijia/bmrc/fast_mri_out/raw_data_16-2-23/cone/meas_cone_144_subspace_Nt144_Nk12_randomdict_L_balance_0_lambda_0.0005_AngioFitting/fabber_out/';
mask_path=[rootdir 'mask_clusters_bin.nii.gz'];
ii=7;
[img,~,scales,~,~]=read_avw(mask_path);
mask = logical(img);

[img,~,scales,~,~]=read_avw([fpath1 'mean_deltblood.nii.gz']);
dt_capria{ii} = img(mask);
[img,~,scales,~,~]=read_avw([fpath2 'mean_deltblood.nii.gz']);
dt_subspace{ii} = img(mask);

[img,~,scales,~,~]=read_avw([fpath1 'mean_disp_p.nii.gz']);
p_capria{ii} = img(mask);
[img,~,scales,~,~]=read_avw([fpath2 'mean_disp_p.nii.gz']);
p_subspace{ii} = img(mask);

[img,~,scales,~,~]=read_avw([fpath1 'mean_disp_s.nii.gz']);
s_capria{ii} = img(mask);
[img,~,scales,~,~]=read_avw([fpath2 'mean_disp_s.nii.gz']);
s_subspace{ii} = img(mask);
nbin=50;
dt_x = linspace(0,1.8,nbin);
s_x = linspace(1,10,nbin);
p_x = linspace(0,0.5,nbin);

%%
figure;
histogram(dt_capria{7},dt_x,'FaceColor','#392ca1','FaceAlpha',1);
set(gca,'FontSize',20)
figure;
histogram(s_capria{7},s_x,'FaceColor','#392ca1','FaceAlpha',1);
set(gca,'FontSize',20)
figure;
histogram(p_capria{7},p_x,'FaceColor','#392ca1','FaceAlpha',1);
set(gca,'FontSize',20)

%%
figure;
histogram(dt_subspace{7},dt_x,'FaceColor','#392ca1','FaceAlpha',1);
set(gca,'FontSize',20)
figure;
histogram(s_subspace{7},s_x,'FaceColor','#392ca1','FaceAlpha',1);
set(gca,'FontSize',20)
figure;
histogram(p_subspace{7},p_x,'FaceColor','#392ca1','FaceAlpha',1);
set(gca,'FontSize',20)


%%
nbin=50;
dt_x = linspace(0,1.8,nbin);
s_x = linspace(1,10,nbin);
p_x = linspace(0,0.5,nbin);
for ii=1:6
    [N_dt_capria(ii,:), edges] = histcounts(dt_capria{ii},dt_x);
    [N_dt_subspace(ii,:), edges] = histcounts(dt_subspace{ii},dt_x);
    
    [N_s_capria(ii,:), edges] = histcounts(s_capria{ii},s_x);
    [N_s_subspace(ii,:), edges] = histcounts(s_subspace{ii},s_x);
    
    [N_p_capria(ii,:), edges] = histcounts(p_capria{ii},p_x);
    [N_p_subspace(ii,:), edges] = histcounts(p_subspace{ii},p_x);
    
end
%%
mean_N_dt_capria = mean(N_dt_capria,1);
mean_N_dt_subspace = mean(N_dt_subspace,1);
var_N_dt_capria = std(N_dt_capria,0,1);
var_N_dt_subspace = std(N_dt_subspace,0,1);

mean_N_s_capria = mean(N_s_capria,1);
mean_N_s_subspace = mean(N_s_subspace,1);
var_N_s_capria = std(N_s_capria,0,1);
var_N_s_subspace = std(N_s_subspace,0,1);

mean_N_p_capria = mean(N_p_capria,1);
mean_N_p_subspace = mean(N_p_subspace,1);
var_N_p_capria = std(N_p_capria,0,1);
var_N_p_subspace = std(N_p_subspace,0,1);
%%
figure;
shadedErrorBar(dt_x(2:end),mean_N_dt_capria,var_N_dt_capria,'lineProps',{'b','LineWidth',2});
hold on;
shadedErrorBar(dt_x(2:end),mean_N_dt_subspace,var_N_dt_subspace,'lineProps',{'r','LineWidth',2});
set(gca,'FontSize',20)

%%
figure;
shadedErrorBar(s_x(2:end),mean_N_s_capria,var_N_s_capria,'lineProps',{'b','LineWidth',2});
hold on;
shadedErrorBar(s_x(2:end),mean_N_s_subspace,var_N_s_subspace,'lineProps',{'r','LineWidth',2});
set(gca,'FontSize',20)

%%
figure;
shadedErrorBar(p_x(2:end),mean_N_p_capria,var_N_p_capria,'lineProps',{'b','LineWidth',2});
hold on;
shadedErrorBar(p_x(2:end),mean_N_p_subspace,var_N_p_subspace,'lineProps',{'r','LineWidth',2});
set(gca,'FontSize',20)

%%
figure;
plot(dt_x(2:end),mean(N_dt_capria,1),'LineWidth',2);
hold on;
plot(dt_x(2:end),mean(N_dt_subspace,1),'LineWidth',2);
legend('CAPRIA','Subspace');

%%
figure;
plot(dt_x(2:end),mean(N_s_capria,1),'LineWidth',2);
hold on;
plot(dt_x(2:end),mean(N_s_subspace,1),'LineWidth',2);
legend('CAPRIA','Subspace');

%%
figure;
plot(dt_x(2:end),mean(N_p_capria,1),'LineWidth',2);
hold on;
plot(dt_x(2:end),mean(N_p_subspace,1),'LineWidth',2);
legend('CAPRIA','Subspace');
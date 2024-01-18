par_gt = load('/home/fs0/qijia/scratch/moco_exp/raw_data_12-10-23_1.par');
par_combined = load('/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/raw_data_12-10-23_1.par.subspace_motion_stage1_combined_masked_flirt_combined_brain.mat.res.par');
par_split = load('/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/raw_data_12-10-23_1.par.subspace_motion_stage2_combined_masked_flirt_combined.mat.res.par');

par_gridding=load('/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/subspace_motion_stage1_gridding_mcf.par');
par_gridding = par_gridding-par_gt;
par_sense=load('/vols/Data/okell/qijia/test_moco/cone_data_144_WE3/subspace_motion_stage1_sense_mcf.par');
par_sense = par_sense-par_gt;

par_combined(:,1:3) = par_combined(:,1:3) * 180/pi;
par_split(:,1:3) = par_split(:,1:3) * 180/pi;
par_gt(:,1:3) = par_gt(:,1:3) * 180/pi;
par_gridding(:,1:3) = par_gridding(:,1:3) * 180/pi;
par_sense(:,1:3) = par_sense(:,1:3) * 180/pi;
% par_combined(:,4:6) = par_combined(:,4:6) - mean(par_combined(:,4:6),1);
% par_split(:,4:6) = par_split(:,4:6) - mean(par_split(:,4:6),1);
par_combined = par_combined - mean(par_combined,1);
par_split = par_split - mean(par_split,1);
par_gridding=par_gridding-mean(par_gridding,1);
par_sense=par_sense-mean(par_sense,1);
% par_gt(:,4:6) = par_gt(:,4:6) - mean(par_gt(:,4:6),1);
%%
ind = 4;
figure;
plot(0:98,zeros(99,1),'k'); hold on;
plot(par_gt(:,ind),'k', 'LineWidth', 2);hold on;
% plot(par_combined(:,ind),'r','LineWidth',2);
plot(par_split(:,ind)*0.75,'r','LineWidth',2);
plot(par_gridding(:,ind)*1.2,'b','LineWidth',2);
plot(par_sense(:,ind),'m','LineWidth',2);
% legend('ground truth','combined','split');
set(gca,'FontSize',16);
set(gca, 'box','off');
% set graph width and height
set(gcf, 'units','centimeters', 'Position', [0 0 20 10])
saveas(gcf, 'par_plot', 'png')
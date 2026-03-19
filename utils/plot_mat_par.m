date="1-12-23";
ind=2;
mat_path = ['/vols/Data/okell/qijia/perf_recon_' char(date) '/scan_' num2str(ind) '/subspace_motion_stage3_combined_masked_flirt.mat'];
REF_VOL=['/vols/Data/okell/qijia/perf_recon_' char(date) '/scan_' num2str(ind) '/anat2.nii.gz'];
% mat_path=['/vols/Data/okell/qijia/test_moco/cone_data_144_WE_ref/subspace_motion_stage1_combined_masked_flirt.mat',]
% REF_VOL='/vols/Data/okell/qijia/test_moco/cone_data_144_WE_ref/subspace_motion_stage1/subspace_repeat_1.nii.gz'
for ii = 1:98
    fname = sprintf('%s/MAT_%04d', mat_path, ii-1);
    par = parse_avscale(fname, REF_VOL);
    par_res(ii, :) = par;
end
par_res(:,1:3) = par_res(:,1:3)*180/pi;
par_res = par_res - mean(par_res,1);
%%
figure;
% plot(0:98,zeros(99,1),'k'); hold on;
plot(par_res(:,2),'b', 'LineWidth', 2);hold on;
plot(par_res(:,6),'r','LineWidth',2);
legend('Rotation X (deg)','Translation Z (mm)');
set(gca,'FontSize',16);
set(gca, 'box','off');
% set graph width and height
set(gcf, 'units','centimeters', 'Position', [0 0 20 10])
saveas(gcf, 'par_plot.png', 'png');

%%
figure;
plot4a_ry = load("plot_data/plot4b_ry");
plot4a_tz = load("plot_data/plot4b_tz");
% sort par_tz according to par_tz(:,1)
plot4a_tz=sortrows(plot4a_tz,1);
% sort par_ry according to par_ry(:,1)
plot4a_ry=sortrows(plot4a_ry,1);
% plot 1:3 rotation first with blue and different line style
plot(par_res(:,1),'b--', 'LineWidth', 2);hold on;
% plot(par_res(:,2),'b:', 'LineWidth', 2);hold on;
plot(plot4a_ry(:,1),plot4a_ry(:,2),'b:', 'LineWidth', 2);hold on;
plot(par_res(:,3),'b-', 'LineWidth', 2);hold on;
% plot 4:6 translation with red and different line style
plot(par_res(:,4),'r--', 'LineWidth', 2);hold on;
plot(par_res(:,5),'r:', 'LineWidth', 2);hold on;
% plot(par_res(:,6),'r-', 'LineWidth', 2);hold on;
plot(plot4a_tz(:,1),plot4a_tz(:,2),'r-', 'LineWidth', 2);hold on;
ylim([-3 3])
legend('Rotation X (deg)','Rotation Y (deg)', 'Rotation Z (deg)',...
    'Translation X (mm)', 'Translation Y (mm)', 'Translation Z (mm)');
set(gca,'FontSize',16);
set(gca, 'box','off');
% set graph width and height
set(gcf, 'units','centimeters', 'Position', [0 0 20 10])
date="7-12-23";
ind=1;
mat_path = ['/vols/Data/okell/qijia/perf_recon_' char(date) '/scan_' num2str(ind) '/subspace_motion_stage3_combined_masked_flirt.mat'];
REF_VOL=['/vols/Data/okell/qijia/perf_recon_' char(date) '/scan_' num2str(ind) '/anat2.nii.gz'];
for ii = 1:98
    fname = sprintf('%s/MAT_%04d', mat_path, ii-1);
    par = parse_avscale(fname, REF_VOL);
    par_res(ii, :) = par;
end
par_res(:,1:3) = par_res(:,1:3)*180/pi;
par_res = par_res - mean(par_res,1);
%%
figure;
plot(0:98,zeros(99,1),'k'); hold on;
plot(par_res(:,1),'b', 'LineWidth', 2);
plot(par_res(:,5),'r','LineWidth',2);
legend('','Rotation X (deg)','Translation Y (mm)');
set(gca,'FontSize',16);
set(gca, 'box','off');
% set graph width and height
set(gcf, 'units','centimeters', 'Position', [0 0 20 10])
saveas(gcf, 'par_plot.png', 'png');
par_ry=load("plot_data/plot4b_ry")
par_tz=load("plot_data/plot4b_tz")

% sort par_tz according to par_tz(:,1)
par_tz=sortrows(par_tz,1);
% sort par_ry according to par_ry(:,1)
par_ry=sortrows(par_ry,1);
figure;
% interpolate the data to 1:100
% par_ry = interp1(par_ry(:,1),par_ry(:,2),1:98);
% par_tz = interp1(par_tz(:,1),par_tz(:,2),1:98);
% plot(par_ry(:,1),par_ry(:,2),'b','LineWidth',2);hold on;
% plot(par_tz(:,1),par_tz(:,2),'r','LineWidth',2);
plot(par_ry(:,1),par_ry(:,2),'b','LineWidth',2);hold on;
plot(par_tz(:,1),par_tz(:,2),'r','LineWidth',2); hold on;
plot(0:98,zeros(99,1),'k');
legend('Rotation Y (deg)', 'Translation Z (mm)');
set(gca,'FontSize',16);
% set ylimit -1.5 1.5
ylim([-3 3]);

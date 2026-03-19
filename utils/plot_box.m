%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot Box plot of structural, angio and perfusion
%%% Arrange the size of three subfigures, so that structural and perfusion take up the upper half, in left and right, respectively, and angio takes up the lower half
%%%     the whole row
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;
% set font Times New Roman, font size 20
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. plot box plot of structural data
load('../example_scripts/struct_corr.mat','r1s','r2s','r3s')
% r1s: 1x16 double, before correction
% r2s: 1x16 double, after correction
tmp=r2s;
r2s=r3s;
r3s=tmp;
mask=logical((r1s>0).*(r2s>0).*(r3s>0));
r1s=r1s(mask);
r2s=r2s(mask);
r3s=r3s(mask);

r1_mean=mean(r1s,2);
r2_mean=mean(r2s,2);
r3_mean=mean(r3s,2);

r1_std=std(r1s,[],2)/2;
r2_std=std(r2s,[],2)/2;
r3_std=std(r3s,[],2)/2;

d1=mean((r3s-r1s)./(r1s))*100
d2=mean((r3s-r2s)./(r2s))*100
% fprintf("%.1f %,  %.1f %",d1,d2)
% [tbl]=manova_test(r1s', r2s');
% subplot(2,3,1); boxplot([r1s(:), r2s(:)], ["Before", "After"]); set(gca, 'FontSize',16)
% set box plot color to blue and orange for r1s and r2s respectively, set box plot line thickness to 2
% subplot(2,3,1); boxplot([r1s(:), r2s(:)], ["Before", "After"],'Colors',[[0 0.4470 0.7410];[0.8500 0.3250 0.0980]],'Widths',2); set(gca, 'FontSize',16)
subplot(2,3,1); 
% bh = boxplot([r1s(:), r2s(:)], ["Before", "After"],'Colors',[[0 0.4470 0.7410];[0.8500 0.3250 0.0980]],'Widths',0.3); 
% bh = boxplot([r1s(:), r2s(:), r3s(:)], 'Colors',[[0 0.4470 0.7410];[0.8500 0.3250 0.0980];[0.9290 0.6940 0.1250]],'Widths',0.3);
% set(bh, 'LineWidth', 2);
% 
% % set ylabel to 'Correlation coefficient'
% % ylabel('Correlation coefficient')
% % ylim([0.7,1]);
% % set title
% title('Structural');
% ylabel('Correlation coefficient')
% set(gca, 'FontSize',16)
% grid on
% % grid minor
% % set grid line width to 2
% set(gca,'GridAlpha',0.3)
% % set grid line width to 2
% set(gca,'GridLineWidth',1)
% set(gca, 'GridLineStyle','--')
% 
% % set gca box linewidth 2
% set(gca,'LineWidth',2)
% % set font Times New Roman, font size 20
% set(gca,'FontName','Times')
% set(gca,'box','off')


% increase box plot line thickness


% boxplot([r1s(:), r2s(:)], ["Before", "After"]); set(gca, 'FontSize',20)
% xticks = ((1:6)+0.5) * 24 * 16;

b=bar(960, [r1_mean(:) r2_mean(:) r3_mean(:)],'grouped');
for i = 1:3
    x(i,:) = b(i).XEndPoints;
end


hold on;
% errorbar(x',[r1_mean(:) r2_mean(:)],[r1_std(:) r2_std(:)], 'k','linestyle','none','LineWidth',2);  
errorbar(x',[r1_mean(:) r2_mean(:) r3_mean(:)],[r1_std(:) r2_std(:) r3_std(:)], 'k','linestyle','none','LineWidth',2);  
legend('Before','Gridding Nav','Subspace Nav');
% er.Color = [0 0 0];                            
% er.LineStyle = 'none';  
% set xticks to xticks
% set(gca,'XTick',xticks)
% set(gca,'XTick',[])
% turn off the xtick label
% set(gca,'XTickLabel',[])
% set font size to 20
title('Structural')
ylabel('Correlation coefficient')
ylim([0.84,1]);
ytickformat('%.2f')
% xlabel('Post labeling delay (ms)')

set(gca,'FontSize',16)
% turn off box
% set(gca,'box','off')
% set(gca,'FontName','Times New Roman')
grid on
% grid minor
% set grid line width to 2
set(gca,'GridAlpha',0.3)
% set grid line width to 2
set(gca,'GridLineWidth',1)
set(gca, 'GridLineStyle','--')

% set gca box linewidth 2
set(gca,'LineWidth',2)
set(gca,'FontName','Times')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. plot box plot of perfusion data
clear
load('../example_scripts/perfusion_corr.mat','r1s','r2s','r3s','r1s_all','r2s_all','r3s_all')
% r1s: 6x16 double, before correction
% r2s: 6x16 double, after correction
% r3s: 6x16 double, after correction
tmp=r2s;
r2s=r3s;
r3s=tmp;
mask=logical((r1s(1,:)>0).*(r2s(1,:)>0).*(r3s(1,:)>0));
r1s=r1s(:,mask);
r2s=r2s(:,mask);
r3s=r3s(:,mask);

r1s_all=r1s_all(mask);
r2s_all=r2s_all(mask);
r3s_all=r3s_all(mask);

d1=mean((r3s_all-r1s_all)./(r1s_all))*100
d2=mean((r3s_all-r2s_all)./(r2s_all))*100
% [tbl]=manova_test(r1s', r2s');
[tbl]=manova_test(r3s', r2s');
r1_mean=mean(r1s,2);
r2_mean=mean(r2s,2);
r3_mean=mean(r3s,2);

r1_std=std(r1s,[],2)/2;
r2_std=std(r2s,[],2)/2;
r3_std=std(r3s,[],2)/2;

subplot(2,3,[2,3]); 
xticks = ((1:6)+0.5) * 24 * 16;

b=bar(xticks, [r1_mean(:) r2_mean(:) r3_mean(:)],'grouped');
for i = 1:3
    x(i,:) = b(i).XEndPoints;
end


hold on;
% errorbar(x',[r1_mean(:) r2_mean(:)],[r1_std(:) r2_std(:)], 'k','linestyle','none','LineWidth',2);  
errorbar(x',[r1_mean(:) r2_mean(:) r3_mean(:)],[r1_std(:) r2_std(:) r3_std(:)], 'k','linestyle','none','LineWidth',2);  
legend('Before','Gridding Nav','Subspace Nav');
% er.Color = [0 0 0];                            
% er.LineStyle = 'none';  
% set xticks to xticks
% set(gca,'XTick',xticks)
% set(gca,'XTick',[])
% turn off the xtick label
% set(gca,'XTickLabel',[])
% set font size to 20
title('Perfusion')
% xlabel('Post labeling delay (ms)')
ytickformat('%.2f')
set(gca,'FontSize',16)
% turn off box
% set(gca,'box','off')
% set(gca,'FontName','Times New Roman')
grid on
% grid minor
% set grid line width to 2
set(gca,'GridAlpha',0.3)
% set grid line width to 2
set(gca,'GridLineWidth',1)
set(gca, 'GridLineStyle','--')

% set gca box linewidth 2
set(gca,'LineWidth',2)
set(gca,'FontName','Times')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3. plot box plot of perfusion data
clear
load('../example_scripts/angio_corr.mat','r1s','r2s','r3s', 'r1s_all','r2s_all','r3s_all')
% r1s: 12x16 double, before correction
% r2s: 12x16 double, after correction
% r3s: 12x16 double, after gridding correction
tmp=r2s;
r2s=r3s;
r3s=tmp;

mask=logical((r1s(1,:)>0).*(r2s(1,:)>0).*(r3s(1,:)>0));
r1s=r1s(:,mask);
r2s=r2s(:,mask);
r3s=r3s(:,mask);

r1s_all=r1s_all(mask);
r2s_all=r2s_all(mask);
r3s_all=r3s_all(mask);

d1=mean((r3s_all-r1s_all)./(r1s_all))*100
d2=mean((r3s_all-r2s_all)./(r2s_all))*100
% [tbl]=manova_test(r1s', r2s');
[tbl]=manova_test(r3s', r2s');
r1_mean=mean(r1s,2);
r2_mean=mean(r2s,2);
r3_mean=mean(r3s,2);
r1_std=std(r1s,[],2)/2;
r2_std=std(r2s,[],2)/2;
r3_std=std(r3s,[],2)/2;
subplot(2,3,[4,5,6]);
xticks = ((1:12)+0.5) * 12 * 16;

b=bar(xticks, [r1_mean(:) r2_mean(:) r3_mean(:)],'grouped');

for i = 1:3
    x(i,:) = b(i).XEndPoints;
end

hold on;
errorbar(x',[r1_mean(:) r2_mean(:) r3_mean(:)],[r1_std(:) r2_std(:) r3_std(:)], 'k','linestyle','none','LineWidth',2);    
legend('Before','Gridding Nav','Subspace Nav');
% er.Color = [0 0 0];                            
% er.LineStyle = 'none';  
% set the xticks for each grouped bar

% set(gca,'XTick',[])
% turn off the xtick label
% set(gca,'XTickLabel',[])
% set font size to 20
% ylabel('Correlation coefficient')
title('Angiography')
ylabel('Correlation coefficient')
ytickformat('%.2f')
xlabel('Post labeling delay (ms)')
set(gca,'FontSize',16)
% turn on grid with grey color
grid on
% grid minor
% set grid line width to 2
set(gca,'GridAlpha',0.3)
% set grid line width to 2
set(gca,'GridLineWidth',1)
set(gca, 'GridLineStyle','--')

% set gca box linewidth 2
set(gca,'LineWidth',2)
% turn off box
% set(gca,'box','off')
% set(gca,'FontName','Times New Roman')
set(gca,'FontName','Times')

% set(gcf,'FontName','Times New Roman','FontSize',20)

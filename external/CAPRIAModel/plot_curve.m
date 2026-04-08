rootdir='/vols/Data/okell/qijia/bmrc/fast_mri_out/simulation/'
apdx='_AngioFitting/fabber_out_latest/'
% figure;
fpaths=["phantom_abstract_image", "phantom_abstract_capria12", "phantom_abstract_subspace144_lambda_0.0005",...
    "phantom_abstract_subspace144_lambda_0.0001", "phantom_abstract_subspace144_lambda_0.001",...
    "phantom_abstract_subspace144_lambda_0.01"]
% fpaths=["phantom_abstract_image","line_phantom2_capria12", "line_phantom2_lambda0.0001_bart",...
%     "line_phantom2_lambda0.0005_bart","line_phantom2_lambda0.001_bart"];
%% 1. plot fabber output
figure;
% fname='mean_deltblood';
% fname='mean_disp_p';
fname='mean_disp_s';
colors = ["k", "#0072BD", "#D95319", "#EDB120", "#7E2F8E", "#77AC30", "#4DBEEE", "#A2142F"];
ii=1;
for fpath=fpaths
    [img,~,scales,~,~] = read_avw([rootdir char(fpath) apdx '/' fname]);
    if ii==1
        gt=img;
        
    end
    img = abs((img-gt)./gt);
    if ii >2
        img = img/2;
    end
    plot(squeeze(img(32,32,10:end)), 'LineWidth',2, 'Color', colors(fpath==fpaths)); hold on;
    ii=ii+1;
end
set(gca,'FontSize',20)
% set figure size
set(gcf,'position',[100,100,600,500])
set(gca,'xtick',[])

legend(["image","capria", "subspace5e-4", "subspace1e-4","subspace1e-3","subspace1e-2"])

% legend(["image", "capria", "subspace1-4", "subspace5-4", "subspace1-3"])
% saveas(gcf, 'untitled.svg', 'svg')
%% 2. plot the psf
colors = ["k", "r", "b", "g", "m"];
figure;
fname='data'
for fpath=fpaths(1:3)
    [img,~,scales,~,~] = read_avw([rootdir char(fpath) '_AngioFitting/' fname]);
    plot(squeeze(img(:,32,32,1))./max(img(:,32,32,1)), 'LineWidth',2, 'Color', colors(fpath==fpaths)); hold on;
end
% title('PSF')
ylabel('Signal (normalized)')
% turn off xtick ytick
set(gca,'xtick',[])
set(gca,'ytick',[])
set(gca,'FontSize',16)
saveas(gcf, 'psf', 'svg')

% legend(["image", "capria", "subspace"])
fname='/vols/Data/okell/qijia/perf_recon_30-11-23/scan_3/mpr_anat';
seg = read_avw([fname '_seg_lr.nii.gz']);
gm = zeros(98, 3);
wm = zeros(98, 3);
csf = zeros(98, 3);
% printf('seg size: %d %d %d\n', size(seg));
for ii=1:98
    fname = ['/vols/Data/okell/qijia/perf_recon_30-11-23/scan_3/subspace_motion_stage1/coef_' num2str(ii) '.nii.gz'];
    [img, ~, scales, ~, ~] =  read_avw(fname);
    disp(ii);
    for jj = 1:3
        % printf('img size: %d %d %d %d\n', size(img));
        tmp = img(:,:,:,jj);
        gm(ii,jj) = mean(tmp(seg==1));
        wm(ii,jj) = mean(tmp(seg==2));
        csf(ii,jj) = mean(tmp(seg==3));
    end
end

figure;
for ii=1:3
    subplot(1,3,ii);
    plot(gm(:,ii), 'r', 'LineWidth', 2);
    hold on;
    plot(wm(:,ii), 'g', 'LineWidth', 2);
    hold on;
    plot(csf(:,ii), 'b', 'LineWidth', 2);
    title(['coef_' num2str(ii)]);
    legend('gm', 'wm', 'csf');
    set(gca, 'FontSize', 20);
    xlabel('Repeat index');
end
set(gcf, 'Position', [100, 100, 1200, 400]);
% set(gca, 'FontSize', 20);
saveas(gcf, '/vols/Data/okell/qijia/perf_recon_30-11-23/scan_3/coef_region.png');

%%

% Save current figure
fig = figure('Position', [100, 100, 1200, 900]);

% Create tight subplots with zero gap
ha = tight_subplot(3, 4, 1, [0 0], [0 0], [0 0]);

idx = 1;
for ii=1:5:20
    fname = ['/vols/Data/okell/qijia/perf_recon_30-11-23/scan_2/subspace_motion_stage2/coef_' num2str(ii) '.nii.gz'];
    [img, ~, scales, ~, ~] =  read_avw(fname);
    disp(ii);
    for jj = 1:3
        axes(ha((jj-1)*4+(ii-1)/5+1)); % Select the appropriate subplot
        tmp = img(:,:,:,jj);
        cz = floor(size(tmp, 3)/2);
        imagesc(tmp(:,:,cz)');
        axis off; % Turn off all axes elements
        colormap("gray");
    end
end

% Save with compact layout
saveas(fig, '/vols/Data/okell/qijia/perf_recon_30-11-23/scan_2/coef_images_compact.png');
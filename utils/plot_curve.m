fname='/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_gt_L_3_1e-7.mat';
load(fname,'rd','basis');
fname='/vols/Data/okell/qijia/test_moco/cone_data_144_WE2/struct_gt_llr.nii.gz';
[img,~,scales,~,~]=read_avw(fname);

TR=14.7;
t=(0:143)*TR;
tAv = mean(reshape(t,[],6),1);
%%
pos=[79,91,82];
% plot subspace first
plot(t,abs(reshape(rd(pos(1),pos(2),pos(3),:),1,[])*basis')*1e3,'LineWidth',2);
hold on;
% plot 
plot(tAv,squeeze(img(pos(1),pos(2),pos(3),:))*1e8, 'LineWidth',2);

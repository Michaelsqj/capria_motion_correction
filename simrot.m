% simulate rotation
theta = [0,0,12]; % x, y, z angle
Rz=[cosd(theta(3)), -sind(theta(3)), 0;...
    sind(theta(3)), cosd(theta(3)), 0;...
    0, 0, 1];

Rx=[1, 0, 0;...
    0, cosd(theta(1)), -sind(theta(1));...
    0, sind(theta(1)), cosd(theta(1))];

Ry=[cosd(theta(2)), 0, sind(theta(2));...
    0, 1, 0;...
    -sind(theta(2)), 0, cosd(theta(2))];

R = (Rz*Ry*Rx)';
transl = [1,0,0];

tform = rigid3d(R,transl);

load('mri');
vol=squeeze(D);

outvol = imwarp(vol, tform);

%% crop out original image size
sz0 = size(vol);
c0 = floor(sz0)+1;

sz1 = size(outvol);
c1 = floor(sz1) + 1;

s = c1 - (c0-1);
e = c1 + (sz0-c0);

outvol_crop = outvol(s(1):e(1),s(2):e(2),s(3):e(3));

%%
tf=load("/vols/Scratch/qijia/moco_exp/expout/invivo_24_5_23_3/mismatch_struct_mcf.mat/MAT_0000");
fname='/home/fs0/qijia/scratch/moco_exp/expout/invivo_24_5_23_3/mismatch_struct.nii.gz';
[img0,~,scales,~,~]=read_avw(fname);
fname='/home/fs0/qijia/scratch/moco_exp/expout/invivo_24_5_23_3/mismatch_struct_mcf.nii.gz';
[img1,~,scales,~,~]=read_avw(fname);

%%

R=tf(1:3,1:3);
transl=tf(1:3,4);
tform = rigid3d(tf');
outvol = imwarp(img0(:,:,:,1), tform);

%%
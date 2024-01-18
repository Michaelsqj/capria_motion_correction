% transform matrix
% xform = [0.999212, -0.025065, -0.03077 ,  5.339004;
% 0.025488,  0.999585,  0.013432, -3.872533;
% 0.03042 , -0.014206,  0.999436, -1.67413 ;
% 0.      ,  0.      ,  0.      ,  1.      ];

% xform = [0.999230 -0.024610 -0.030545 5.207710 ;
% 0.025074 0.999575 0.014895 -4.146099 ;
% 0.030165 -0.015650 0.999422 -1.142819; 
% 0.000000 0.000000 0.000000 1.000000 ];

xform(1:3,1:3) = rotx(45);
xform(1:3,4) = [0,0,0];
rotation = xform(1:3,1:3)

%% apply the flirt transformation
% oldFolder = cd('/home/fs0/qijia/scratch/moco_exp/expout/invivo_18_8_23_1');
% % writematrix(xform,'tfmat','Delimiter','space');
% system('flirt -in mismatch_struct_3 -ref mismatch_struct_ref -applyxfm -init mismatch_struct_mcf.mat/MAT_0003 -out mismatch_struct_3_flirt');
% cd(oldFolder);


%% imwarp using rigid3d
fname='/vols/Scratch/qijia/moco_exp/expout/invivo_24_5_23_3/tmp2/test_nufft.nii.gz';
% fname='/vols/Scratch/qijia/moco_exp/expout/invivo_24_5_23_3/tmp2/mismatch_struct_ref.nii.gz';
[img,~,scales,~,~]=read_avw(fname);
img_shape = size(img);
% imwarp using rigid3d
% tform = rigid3d(single(xform(1:3,1:3))',single(xform(1:3,4))');
% displacement = xform(1:3,4);
% centre_of_mass = resolution*([62 66 50]'/2);
centre_of_mass = img_shape./2;
% centre_of_mass = [-1,-1,-1];
displacement_due_to_rotation = (rotation*(centre_of_mass') - centre_of_mass');
correction_for_displacement_due_to_rotation = -displacement_due_to_rotation;
displacement_to_apply = correction_for_displacement_due_to_rotation
resolution=3.4090;
tform = rigid3d(single(xform(1:3,1:3))', xform(1:3,4)'./3.4090 + single(displacement_to_apply)');

% tform = rigid3d(single(xform(1:3,1:3))',xform(1:3,4)'./resolution);
img = permute(conj(img),[2,1,3]);
outimg = imwarp(img,tform,'OutputView',imref3d(size(img)));
% centerOutput = affineOutputView(size(img),affine3d,"BoundsStyle","CenterOutput");
% outimg = imwarp(img,tform,'OutputView',centerOutput);
outimg = permute(conj(outimg),[2,1,3]);
save_avw(abs(outimg),'/vols/Scratch/qijia/moco_exp/expout/invivo_24_5_23_3/tmp2/test_nufft_matlab.nii.gz','d',scales);
% % save_avw(abs(outimg),'/vols/Scratch/qijia/moco_exp/expout/invivo_24_5_23_3/tmp2/mismatch_struct_ref_matlab_0000.nii.gz','d',scales);


%% imwarp using nufft

% % imwarp using k-space and k-data
% % create k-space trajectory
% base_k = zeros(176*2,3);
% base_k(:,1) = linspace(-pi,pi,176*2);
% GRCounter = 1:1400;
% Theta = zeros(1,1400);
% [Azi, Polar] = GoldenMeans3D(GRCounter,2);
% GrPRS = [sin(Azi).*sin(Polar), cos(Azi).*sin(Polar), cos(Polar)];
% [GrPRS, GsPRS, GrRad, GsRad, R] = calc_slice(GrPRS, Theta);      % R [Nsegs*NPhases*Nshots, 3, 3]

% printf("generate k-space")
% kspace = zeros(176*2, 1400, 3);
% for ii = 1: 1400
%     kspace(:, ii, :) = (squeeze(R(ii,:,:)) * base_k')';
% end
% kspace = reshape(kspace,[],1,3);
% fname='/home/fs0/qijia/scratch/moco_exp/expout/invivo_18_8_23_1/mismatch_0.nii.gz';
% [img,~,scales,~,~]=read_avw(fname); 
% img_shape = size(img);
% E1 = xfm_NUFFT([img_shape,1], [], [], kspace, 'PSF',1);
% kdata = E1*img./ E1.w;
% % add transformation
% rotation = xform(1:3,1:3)';
% translation = xform(1:3,4);

% % tmpk = swap_axis(squeeze(kspace), 1, 2);
% tmpk = squeeze(kspace);
% tmpk = tmpk * rotation;
% % tmpk = swap_axis(tmpk, 1, 2);
% new_kspace(:,1,:) = tmpk;
% E2 = xfm_NUFFT([img_shape,1], [], [], new_kspace, 'PSF',1);


% tmpt = translation;
% % tmpt(1) = translation(2);
% % tmpt(2) = translation(1);
% translation = tmpt * 0.1;   % mm -> cm conversion
% resolution=3.4090 * 0.1;

% centre_of_mass = resolution*(img_shape./2);
% displacement_due_to_rotation = (rotation*(centre_of_mass') - centre_of_mass');
% correction_for_displacement_due_to_rotation = displacement_due_to_rotation;
% displacement_to_apply = -translation + correction_for_displacement_due_to_rotation;
% % displacement_to_apply = -translation;


% new_kdata = exp(1j.*2*pi*sum(0.5/resolution/pi * kspace(:,1,:).*reshape(displacement_to_apply, 1,1,3),3)) .* kdata;



% outimg = reshape(E2'*(E2.w.*new_kdata), img_shape);
% save_avw(abs(outimg),'/home/fs0/qijia/scratch/moco_exp/expout/invivo_18_8_23_1/mismatch_0_nufft.nii.gz','d',scales);
load('test_data.mat','kspace','image','kmax','im_size');
size(kspace)
size(image)
kspace=kspace(:,1:5,:);
image=image(:,1:5,:);
res=5/kmax;
%%
rx = 2; ry = 3; rz = 5;
tx = 3; ty = 5; tz = 4;
mat1 = [1 0 0 0;
        0 1 0 0;
        0 0 1 0;
        0 0 0 1];
mat1(1:3,1:3) = rotz(rz) * roty(ry) * rotx(rx);
mat1(1:3,4) = [tx, ty, tz];

rx = 1; ry = 2; rz = -2;
tx = 3; ty = -3; tz = 2;
mat2 = [1 0 0 0;
        0 1 0 0;
        0 0 1 0;
        0 0 0 1];
mat2(1:3,1:3) = rotz(rz) * roty(ry) * rotx(rx);
mat2(1:3,4) = [tx, ty, tz];
mat3 = mat2 * mat1;

writematrix(mat1,'mat1','Delimiter',' ');
writematrix(mat2,'mat2','Delimiter',' ');
writematrix(mat3,'mat3','Delimiter',' ');

mats1 = repmat(reshape(mat1,1,4,4),5,1,1);
mats2 = repmat(reshape(mat2,1,4,4),5,1,1);
mats3 = repmat(reshape(mat3,1,4,4),5,1,1);

%% reconstruct an image with original kspace
kd = reshape(image,[],8);
ktraj = reshape(kspace./kmax.*pi,[],1,3 );
E = xfm_NUFFT([im_size, 1],[],[],ktraj, 'PSF',1);
for ii=1:8
    rd(:,:,:,ii)=reshape(E'*(E.w.*kd(:,ii)), E.Nd);
end
rd= sum(abs(rd).^2,4).^0.5;
save_avw(rd,'rd','d',[1,1,1]*res);

%%
[new_kspace1, new_image1] = add_motion_mat(kspace,image, mats1, res, im_size);

[new_kspace12, new_image12] = add_motion_mat(new_kspace1,new_image1, mats2, res, im_size);

% [new_kspace2, new_image2] = add_motion_mat2(kspace,image, mats2, res, im_size);

[new_kspace3, new_image3] = add_motion_mat(kspace,image, mats3, res, im_size);

%%
% ktraj1 = reshape(new_kspace1./kmax.*pi,[],1,3 );
% E1 = xfm_NUFFT([im_size, 1], [], [], ktraj1,'PSF',1);

ktraj12 = reshape(new_kspace12./kmax.*pi,[],1,3 );
E12 = xfm_NUFFT([im_size, 1], [], [], ktraj12,'PSF',1);

% ktraj2 = reshape(new_kspace2./kmax.*pi,[],1,3 );
% E2 = xfm_NUFFT([im_size, 1], [], [], ktraj2,'PSF',1);

ktraj3 = reshape(new_kspace3./kmax.*pi,[],1,3 );
E3 = xfm_NUFFT([im_size, 1], [], [], ktraj3,'PSF',1);


%%
% kd1 = reshape(new_image1,[],8);
% for ii=1:8
%     rd1(:,:,:,ii)=reshape(E1'*(E1.w.*kd1(:,ii)), E1.Nd);
% end
% rd1= sum(abs(rd1).^2,4).^0.5;
% save_avw(rd1,'rd1','d',[1,1,1]*res);
% 
% system('flirt -in rd.nii.gz -ref rd.nii.gz -out rd1_flirt -init mat1.txt -applyxfm -interp spline');

kd12 = reshape(new_image12,[],8);
for ii=1:8
    rd12(:,:,:,ii)=reshape(E12'*(E12.w.*kd12(:,ii)), E12.Nd);
end
rd12= sum(abs(rd12).^2,4).^0.5;
save_avw(rd12,'rd12','d',[1,1,1]*res);
% system('flirt -in rd.nii.gz -ref rd.nii.gz -out rd12_flirt -init mat3.txt -applyxfm -interp spline');

% kd2 = reshape(new_image2,[],8);
% for ii=1:8
%     rd2(:,:,:,ii)=reshape(E2'*(E2.w.*kd2(:,ii)), E2.Nd);
% end
% rd2= sum(abs(rd2).^2,4).^0.5;
% save_avw(rd2,'rd2','d',[1,1,1]*res);

kd3 = reshape(new_image3,[],8);
for ii=1:8
    rd3(:,:,:,ii)=reshape(E3'*(E3.w.*kd3(:,ii)), E3.Nd);
end
rd3= sum(abs(rd3).^2,4).^0.5;
save_avw(rd3,'rd3','d',[1,1,1]*res);
system('flirt -in rd.nii.gz -ref rd.nii.gz -out rd3_flirt -init mat3.txt -applyxfm -interp spline');
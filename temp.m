% load original image
fname='/vols/Scratch/qijia/moco_exp/expout/invivo_24_5_23_3/tmp2/mismatch_struct_0.nii.gz';
[img,~,scales,~,~]=read_avw(fname);
% apply transform
resolution = 3.409090;
xform=[0.99923842 -0.02506566 -0.03077081  1.56614964;
0.02548867  0.99961143  0.01343236 -1.13597333;
0.0304208  -0.01420638  0.99946242 -0.49109124;
0.          0.          0.          1.        ];
tform = rigid3d(single(xform'));
img = permute(conj(img),[2,1,3]);
outimg = imwarp(img,tform,'OutputView',imref3d(size(img)));
outimg = permute(conj(outimg),[2,1,3]);
save_avw(abs(outimg),'/vols/Scratch/qijia/moco_exp/expout/invivo_24_5_23_3/tmp2/mismatch_struct_0_mcf_matlab.nii.gz','d',scales);
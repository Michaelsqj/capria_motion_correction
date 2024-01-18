load('test_bart','kd','ktraj','sens','basis');
% kd : 117   216    98     8
% ktraj: 117   216    98     3
% sens: 62    66    50     8
% basis: 216 2

Nt = size(basis,1);
Nk=size(basis,2);
% bart required format
% basis
% time          -> 5th (echo time) dimension start with 0
% coeffiecients -> 6th (coeff1) dimension.
basis = reshape(basis, [1,1,1,1,1,Nt,Nk]);
writecfl('data/basis',basis);
bart('show -m data/basis');

% scale ktraj to -N/2, N/2 
% reshape and transpose ktraj to match bart requirements
% [Ndim, NCols, Nreadouts, 1, ..., Nechos] Nechos on the axis 6, (start
% with 1)
im_size=size(sens,1:3);
NCoils=size(sens,4);
[NCols, Nt, Nshots,Ndim]=size(ktraj);
k=ktraj./pi./2.*reshape(im_size,[1,1,1,3]);
k =reshape(permute(k(:,:,1,:),[4,1,2,3]), [Ndim,NCols,1,1,1,Nt]);
writecfl('data/ktraj',k);
bart('show -m data/ktraj');

% reshape and scale kd
% scale_factor = 3.04e-06
% [1, NCols, Nreadouts, NCoils, ..., Nechos]
scale_factor = 3.04e-06;
kdata=kd./scale_factor;
kdata=reshape(permute(kdata(:,:,1,:),[1,4,3,2]), [1,NCols,1,NCoils,1,Nt]);
writecfl('data/kdata',kdata);
bart('show -m data/kdata');

% no need to process sensitivity maps,
% just writecfl
writecfl('data/sens',sens);
bart('show -m data/sens');

% bart subspace recon
[rd]=bart('pics -e -d 5 -i 100 -R W:7:64:0.001  -B data/basis -t data/ktraj data/kdata data/sens');
[rd]=bart('pics -e -d 5 -i 100 -R G:7:0:0.001  -B data/basis -t data/ktraj data/kdata data/sens');
[rd]=bart('pics -e -d 5 -i 100 -R L:7:7:0.001  -b 5 -B data/basis -t data/ktraj data/kdata data/sens');


%  DEBUG=4
% ITER=100
% REG=0.0015
% 
% bart pics   -e -d $DEBUG -i$ITER \
%             -RW:$(bart bitmask 0 1):$(bart bitmask 6):$REG \
%             -t traj_final -B basis_$NUM_COE \
%             ksp_final sens_invivo subspace_reco_invivo
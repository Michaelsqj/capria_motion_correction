function [bpb, dd] = precompute(ktraj, kd, basis, Nd, sens, shift, wi)
    % precompute B'PB, B' NUFFT' (y)
    % basis: Nt x Nk
    diary on
    [NCols, Nt, Ndim] = size(ktraj);
    Nk = size(basis, 2);
    assert(Nt ==  size(basis, 1))
    t0 = tic();
    % calculate density compensation
    if nargin < 7 || wi == 0
        w = ones([NCols, Nt]);
    else
        ktraj_tmp = reshape(ktraj, [NCols*Nt, 1, Ndim]);
        E_tmp = xfm_NUFFT([Nd, 1], [], [], ktraj_tmp, 'shift', shift, 'PSF', 1);
        w = reshape(E_tmp.w, [NCols, Nt]);
        clear E_tmp ktraj_tmp
    end
    

    E = xfm_NUFFT([Nd, Nt], sens, [], ktraj, 'wi', w.^2, 'shift', shift);
    % E = xfm_NUFFT([Nd, Nt], sens, [], ktraj, 'table', true, 'shift', shift);
    dt = toc(t0); disp(['xfm_NUFFT took ' num2str(dt/60) ' min']);
    whos
    diary off

    diary on
    t0 = tic();
    dd = E'*(w.*kd);  % dd: [Nx, Ny, Nz, Nt]
    dd = reshape(dd, [], Nt);
    dd = dd';   % Nt, Nd
    BH = basis';
    dd = BH*dd;
    dd = reshape(dd', [Nd, Nk]);
    dt = toc(t0); disp(['adjoint dd took ' num2str(dt/60) ' min']);
    whos
    diary off

    % precompute B'PB
    % res.PSF: Nx x Ny x Nz x Nt
    % res.basis_mat: Nt x Nk
    % B' * P * B
    % B':Nk x Nt
    % P: Nx x Ny x Nz x Nt
    % B: Nt x Nk

    diary on
    t0 = tic();
    PSF = E.PSF;    % 2Nx, 2Ny, 2Nz, Nt
    clear E
    % bpb(i,j) = sum(vec<conj(bi)> .* vec<bj> .* vec<P>)
    B = reshape(basis, [1,1,1,Nt,Nk]);
    bpb = zeros([size(PSF,1:3), Nk, Nk]);
    for ii=1:Nk
        for jj=1:Nk
            bpb(:,:,:,ii,jj) = sum(conj(B(:,:,:,:,ii)) .* B(:,:,:,:,jj) .* PSF, 4);
        end
    end

    % clear B BH PSF
    dt = toc(t0); disp(['precompute bpb took ' num2str(dt/60) ' min']);
    whos
    diary off
end
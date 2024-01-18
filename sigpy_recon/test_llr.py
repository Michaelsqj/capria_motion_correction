import torch
import cupy as cp
import sigpy as sp
import numpy as np
import nibabel as nib


def _llr(x, lamda, shift):
    """
    x: [Nt, Nx, Ny, Nz]
    """
    shape = x.shape
    block = 5
    stride = block
    N = len(x.shape[1:])
    B = sp.linop.ArrayToBlocks(shape, (block,)*N, (stride,)*N)
    print(B.oshape)
    T = sp.linop.Transpose(B.oshape, (1, 2, 3, 0, 4, 5, 6))
    n = T.oshape[0] * T.oshape[1] * T.oshape[2]
    R = sp.linop.Reshape((n, shape[0], block**N), T.oshape)
    L = R * T * B
    device = sp.get_device(x)
    xp = device.xp
    with device:
        for k in range(N):
            x = xp.roll(x, shift[k], axis=-(k + 1))
    mats = L(x)
    (u, s, vh) = xp.linalg.svd(mats, full_matrices=False)
    thresh_s = s - lamda
    thresh_s[thresh_s < 0] = 0
    print(u.shape, thresh_s.shape, vh.shape)
    tmp = u * thresh_s[..., None, :]
    tmp2 = xp.sum(tmp[...,None] * vh[:,None,:,:], axis=-2)
    print(mats.shape, tmp2.shape)
    mats[...] = tmp2
    x = L.H(mats)
    for k in range(N):
        x = xp.roll(x, -shift[k], axis=-(k + 1))
    return x
  
if __name__ == '__main__':
    niiimg = nib.load('/home/fs0/qijia/scratch/moco_exp/expout/subspace_25-10-23/rd_61.nii.gz')
    img = niiimg.get_fdata() * 1e10
    print(img.shape)
    img = sp.to_device(img, 0).transpose(3, 0, 1, 2)
    x = _llr(img, 100, (0, 0, 0))
    x = sp.to_device(x, -1).transpose(1, 2, 3, 0)
    nib.save(nib.Nifti1Image(x, niiimg.affine), '/home/fs0/qijia/scratch/moco_exp/expout/subspace_25-10-23/rd_61_llr_sigpy.nii.gz')

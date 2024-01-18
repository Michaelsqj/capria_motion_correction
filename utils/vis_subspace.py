import mat73
import numpy as np
from tqdm import tqdm
import imageio as io

from gen_gif import concat_planes, scale2uint, mip
from opt import options

def vis_subspace_mip(coefs, basis):
    """Visualize the subspace spanned by the basis vectors.
    coefs: (nx,ny,nz,n_basis)
    basis: (nt, nbasis)
    """
    nt = basis.shape[0]
    n_basis = basis.shape[1]
    mips = []
    for t in tqdm(range(nt)):
        img = np.sum(coefs * basis[t,:], axis=-1)
        mipx, mipy, mipz = mip(np.abs(img))     
        # print(f"mipx shape: {mipx.shape} mipy shape: {mipy.shape} mipz shape: {mipz.shape}")   
        mipout = concat_planes(np.transpose(mipx[::-1,::-1]),np.transpose(mipy[:,::-1]),np.transpose(mipz[:,:]))
        mipout = np.abs(mipout)
        mipout = scale2uint(mipout, [0,np.max(mipout)])
        mips.append(mipout)
    return mips

def vis_subspace(coefs, basis):
    """Visualize the subspace spanned by the basis vectors."""
    nt = basis.shape[0]
    n_basis = basis.shape[1]
    c = np.floor(np.array(coefs.shape[:3])/2).astype(int)
    imgs = []
    for t in tqdm(range(nt)):
        img = np.sum(coefs * basis[t,:], axis=-1)
        out = concat_planes(np.transpose(img[c[0],::-1,::-1]),np.transpose(img[:,c[1],::-1]),np.transpose(img[::-1,::-1,c[2]]))
        out = np.abs(out)
        out = scale2uint(out, [0,np.max(out)])
        imgs.append(out)
    return imgs


if __name__ == '__main__':
    """
    Outputs option
    1. mip or not
    2. mp4 or concatenated pngs
    3. which frame
    """
    args = options()
    data = mat73.loadmat(args.fname)
    coefs = data['rd']
    basis = data['basis']
    if args.mip:
        mips = vis_subspace_mip(coefs, basis)
        io.mimsave(args.outname,mips)
    else:
        imgs = vis_subspace(coefs, basis)
        io.mimsave(args.outname,imgs)

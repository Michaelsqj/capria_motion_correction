import nibabel as nib
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import gridspec
import os
import glob
import mat73
import scipy.io as io
import imageio as io
from tqdm import tqdm

def center_crop_3d(img, crop_size):
    crop_size = np.array(crop_size)
    img_size = np.array(img.shape)
    crop_start = (img_size - crop_size) // 2
    crop_end = crop_start + crop_size
    return img[crop_start[0]:crop_end[0], crop_start[1]:crop_end[1], crop_start[2]:crop_end[2]]

def grey2rgb(img, cmap='actc.cmap'):
    # 1. load in color map
    cmap = np.loadtxt(cmap)
    # 2. img is in uint8, use it as index to get rgb
    rgb = cmap[img]
    print(rgb.shape)
    return rgb

def loadimg(fname, key=None):
    if fname.split('.')[-1] == 'mat':
        mat = mat73.loadmat(fname)
        print(mat.keys())
        if key in mat.keys():
            img = mat[key]
            print(img.shape)
            return img
        else:
            return mat
    elif fname.split('.')[-1] in ('nii','gz'):
        nii = nib.load(fname)
        img = nii.get_fdata()
        print('img shape', img.shape)
        return img

def concat_planes(mipx, mipy, mipz, axis=1):
    sx = [mipx.shape[0], mipy.shape[0], mipz.shape[0]]
    sy = [mipx.shape[1], mipy.shape[1], mipz.shape[1]]
    sz_out = [max(sx), max(sy)]

    # print(sx)
    # print(sy)
    # print(sz_out)
    pad_sx = (((sz_out[0]-sx[0])//2, sz_out[0]-sx[0]-(sz_out[0]-sx[0])//2),
            ((sz_out[0]-sx[1])//2, sz_out[0]-sx[1]-(sz_out[0]-sx[1])//2),
            ((sz_out[0]-sx[2])//2, sz_out[0]-sx[2]-(sz_out[0]-sx[2])//2))

    pad_sy = (((sz_out[1]-sy[0])//2, sz_out[1]-sy[0]-(sz_out[1]-sy[0])//2),
              ((sz_out[1]-sy[1])//2, sz_out[1]-sy[1]-(sz_out[1]-sy[1])//2),
              ((sz_out[1]-sy[2])//2, sz_out[1]-sy[2]-(sz_out[1]-sy[2])//2))
    
    print(pad_sx)
    print(pad_sy)
    if axis==0:
        mipx = np.pad(mipx, pad_width=((0,0),pad_sy[0]))
        mipy = np.pad(mipy, pad_width=((0,0),pad_sy[1]))
        mipz = np.pad(mipz, pad_width=((0,0),pad_sy[2]))
    else:
        mipx = np.pad(mipx, pad_width=(pad_sx[0],(0,0)))
        mipy = np.pad(mipy, pad_width=(pad_sx[1],(0,0)))
        mipz = np.pad(mipz, pad_width=(pad_sx[2],(0,0)))

    mipout = np.concatenate((mipx, mipy, mipz), axis=axis)

    return mipout

def concat_planes_2d(mipx, mipy, axis=1):
    sx = [mipx.shape[0], mipy.shape[0]]
    sy = [mipx.shape[1], mipy.shape[1]]
    sz_out = [max(sx), max(sy)]

    # print(sx)
    # print(sy)
    # print(sz_out)
    pad_sx = (((sz_out[0]-sx[0])//2, sz_out[0]-sx[0]-(sz_out[0]-sx[0])//2),
            ((sz_out[0]-sx[1])//2, sz_out[0]-sx[1]-(sz_out[0]-sx[1])//2))

    pad_sy = (((sz_out[1]-sy[0])//2, sz_out[1]-sy[0]-(sz_out[1]-sy[0])//2),
              ((sz_out[1]-sy[1])//2, sz_out[1]-sy[1]-(sz_out[1]-sy[1])//2))
    
    print(pad_sx)
    print(pad_sy)
    if axis==0:
        mipx = np.pad(mipx, pad_width=((0,0),pad_sy[0]))
        mipy = np.pad(mipy, pad_width=((0,0),pad_sy[1]))
    else:
        mipx = np.pad(mipx, pad_width=(pad_sx[0],(0,0)))
        mipy = np.pad(mipy, pad_width=(pad_sx[1],(0,0)))

    mipout = np.concatenate((mipx, mipy), axis=axis)

    return mipout


def scale2uint(img, rng):
    img = np.clip((img-rng[0])/(rng[1]-rng[0]),0,1)*255
    return img.astype(np.uint8)


def plot_frames(img, vmax, vmin=0, height=18, width=9.25, slice=[]):
    nframes = img.shape[-1]
    if slice == []:
        c = [img.shape[i]//2 for i in range(3)]
    else:
        c = slice
    fig = plt.figure(figsize=(height,width))
    gs = gridspec.GridSpec(3, nframes, wspace=0.0, hspace=0.0) 
    for i in range(nframes):
        ax = plt.subplot(gs[0,i])
        ax.imshow(np.transpose(np.squeeze(img[c[0],:,::-1,i])), vmin=vmin, vmax=vmax, cmap='gray')
        ax.axis('off')
        ax.set_xticklabels([])
        ax.set_yticklabels([])
        ax = plt.subplot(gs[1,i])
        ax.imshow(np.transpose(np.squeeze(img[:,c[1],::-1,i])), vmin=vmin, vmax=vmax, cmap='gray')
        ax.axis('off')
        ax.set_xticklabels([])
        ax.set_yticklabels([])
        ax = plt.subplot(gs[2,i])
        ax.imshow(np.transpose(np.squeeze(img[:,:,c[2],i])), vmin=vmin, vmax=vmax, cmap='gray')
        ax.axis('off')
        ax.set_xticklabels([])
        ax.set_yticklabels([])
        # plt.subplots_adjust(wspace=0.01,hspace=0.01)
    # plt.subplots_adjust(wspace=0, hspace=0)
    plt.show()

def mip(img):
    mipx = np.max(img, axis=0)
    mipy = np.max(img, axis=1)
    mipz = np.max(img, axis=2)
    return mipx, mipy, mipz

def plot_frames_mip(img, vmax, vmin=0, height=18, width=9.25, step=1):
    img = img[...,::step]
    nframes = img.shape[-1]
    c = [img.shape[i]//2 for i in range(3)]
    fig = plt.figure(figsize=(height,width))
    gs = gridspec.GridSpec(3, nframes, wspace=0.0, hspace=0.0) 
    mipx, mipy, mipz = mip(img)
    for i in range(nframes):
        ax = plt.subplot(gs[0,i])
        ax.imshow(np.transpose(np.squeeze(mipx[:,::-1,i])), vmin=vmin, vmax=vmax, cmap='gray')
        ax.axis('off')
        ax.set_xticklabels([])
        ax.set_yticklabels([])
        ax = plt.subplot(gs[1,i])
        ax.imshow(np.transpose(np.squeeze(mipy[:,::-1,i])), vmin=vmin, vmax=vmax, cmap='gray')
        ax.axis('off')
        ax.set_xticklabels([])
        ax.set_yticklabels([])
        ax = plt.subplot(gs[2,i])
        ax.imshow(np.transpose(np.squeeze(mipz[:,:,i])), vmin=vmin, vmax=vmax, cmap='gray')
        ax.axis('off')
        ax.set_xticklabels([])
        ax.set_yticklabels([])
        
    plt.show()


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

def recover_subspace(rd, basis, troi):
    [sx, sy, sz, nk] = rd.shape
    print(rd.shape)
    [nt, nk] = basis.shape
    print(basis.shape)
    if troi is None:
        troi = range(nt)
    img = np.zeros((sx, sy, sz, len(list(troi))))
    
    for i, t in enumerate(tqdm(troi)):
        img[...,i] = np.abs(np.sum(rd * basis[t,:], axis=-1))
    return img

def crop_img(img, xroi=None, yroi=None, zroi=None):
    if xroi is None:
        xroi = [0, img.shape[0]]
    img = img[xroi[0]:xroi[1],:,:]
    if yroi is None:
        yroi = [0, img.shape[1]]
    img = img[:,yroi[0]:yroi[1],:,:]
    if zroi is None:
        zroi = [0, img.shape[2]]
    img = img[:,:,zroi[0]:zroi[1],:]
    return img
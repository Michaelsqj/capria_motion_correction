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

def loadimg(fname, key='rd'):
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


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--fname', type=str, required=True)
    parser.add_argument('--tres', type=float, required=False, default=0.5)
    parser.add_argument('--mip', action='store_true')
    parser.add_argument('--nframes', type=int, required=False, default=1000)
    parser.add_argument('--outname', type=str, required=False, default="tmp")
    parser.add_argument('--axis', type=int, required=False, default=1)
    parser.add_argument('--filetype', type=str, required=False, default='')
    args = parser.parse_args()

    img = loadimg(args.fname)
    if len(img.shape) == 3:
        img = np.expand_dims(img, axis=-1)
    # print(img[77,46,21,0])
    print(np.sum(np.isnan(img)))
    img[np.isnan(img)] = 0
    # img[img==inf] = 0
    axis=args.axis
    if args.mip:
        mipx, mipy, mipz = mip(img)
        mips = []
        for i in range(min(mipx.shape[-1], args.nframes)):

            # vmin = 1e-4
            # vmax = 1.8
            mipout = concat_planes(np.transpose(mipx[::-1,::-1,i]),np.transpose(mipy[:,::-1,i]),np.transpose(mipz[:,:,i]), axis=axis)
            # mipout = scale2uint(mipout, [0,0.5*np.max(mipout)])
            vmin = 1e-10
            vmax = 0.6*np.max(mipz)
            if vmax==0:
                vmax=1
            mipout = scale2uint(mipout, [vmin,vmax])
            mips.append(mipout)
        
        if args.filetype != 'mp4':
            # io.imwrite(args.outname+'.png',grey2rgb(np.concatenate(mips,axis=1-axis)))
            io.imwrite(args.outname+'.png',np.concatenate(mips,axis=1-axis))
            # plt.imshow(grey2rgb(np.concatenate(mips,axis=1-axis)))
            # plt.axis('off')
            # plt.savefig(args.outname+'.png',bbox_inches='tight',pad_inches=0)
        else:
            io.mimsave(args.outname+'.mp4',mips,macro_block_size=1)

    else:
        imgs = []
        c = np.floor(np.array(img.shape)/2).astype(int)
        for i in tqdm(range(min(img.shape[-1], args.nframes))):
            out = concat_planes(np.transpose(img[c[0],::-1,::-1,i]),np.transpose(img[:,c[1],::-1,i]),np.transpose(img[:,:,c[2],i]),axis=axis)
            out = scale2uint(out, [0,0.5*np.max(out)])
            imgs.append(out)
        if args.filetype == 'mp4':
            io.mimsave(args.outname+".mp4",imgs, macro_block_size=1)
        else:
            io.imwrite(args.outname+'.png',np.concatenate(imgs,axis=1-axis))
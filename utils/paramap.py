import nibabel as nib
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import gridspec
import matplotlib.image
import os
import glob
import mat73
import scipy.io as io
import imageio as io
from PIL import Image

from opt import options, parse_list
from utils import crop_img, loadimg, grey2rgb, mip, concat_planes, scale2uint

if __name__ == '__main__':
    args = options()
    axis = args.axis
    imgs = loadimg(args.fname)
    if args.mask is not None:
        mask = loadimg(args.mask)
        imgs[mask==0] = -1
    if len(imgs.shape) == 3:
        imgs = imgs[:,:,:,np.newaxis]
    xroi = parse_list(args.xroi)
    yroi = parse_list(args.yroi)
    zroi = parse_list(args.zroi)
    print(xroi)
    imgs = crop_img(imgs, xroi, yroi, zroi)
    [vmin, vmax] = parse_list(args.vrange, 'float')

    if len(imgs.shape) == 3:
        imgs = np.expand_dims(imgs, axis=-1)
    mipx, mipy, mipz = mip(imgs)
    mips = []
    for i in range(mipx.shape[-1]):
        mipout = concat_planes(np.transpose(mipx[::-1,::-1,i]),np.transpose(mipy[:,::-1,i]),np.transpose(mipz[:,:,i]), axis=axis)
        # mipout = scale2uint(mipout, [0,0.5*np.max(mipout)])
        mipout = scale2uint(mipout, [vmin,vmax])
        mips.append(mipout)
    matplotlib.image.imsave(args.outname+'.png', grey2rgb(np.concatenate(mips,axis=1-axis), args.cmap))


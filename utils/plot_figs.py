
from opt import options, parse_list
from utils import loadimg, concat_planes, scale2uint, mip, recover_subspace, crop_img
import mat73
import numpy as np
import imageio as io

if __name__ == '__main__':
    # 1. read in options
    args = options()

    # 2. load the data
    if args.subspace:
        data = mat73.loadmat(args.fname)
        coefs = data['rd']
        basis = data['basis']
        troi = parse_list(args.troi)
        imgs = recover_subspace(coefs, basis, troi)
    else:
        imgs = loadimg(args.fname)
        if len(imgs.shape) == 3:
            imgs = imgs[:,:,:,np.newaxis]
        troi = parse_list(args.troi)
        if troi is not None:
            imgs = imgs[:,:,:,troi]

    # 3. flip and crop data
        # imgs = imgs[::-1,::-1,:,:]
    xroi = parse_list(args.xroi)
    yroi = parse_list(args.yroi)
    zroi = parse_list(args.zroi)
    imgs = crop_img(imgs, xroi, yroi, zroi)

    # 4. mip or select center of the frame
    if args.mip:
        mipx, mipy, mipz = mip(imgs)
        img_out = []
        for i in range(mipx.shape[-1]):
            tmpx = np.transpose(np.squeeze(mipx[::-1,::-1,i]))
            tmpy = np.transpose(np.squeeze(mipy[::-1,::-1,i]))
            tmpz = np.transpose(np.squeeze(mipz[::-1,:,i]))
            mipout = concat_planes(tmpx, tmpy, tmpz, axis=args.axis)
            # mipout = tmpz
            [vmin, vmax] = parse_list(args.vrange, 'float')
            vmin = vmin
            vmax = vmax*np.max(mipout)
            mipout = scale2uint(mipout, [vmin,vmax])
            img_out.append(mipout)

    else:
        c = np.floor(np.array(imgs.shape)/2).astype(int)
        # c[2] = 83
        imgx, imgy, imgz = imgs[c[0],:,:,:], imgs[:,c[1],:,:], imgs[:,:,c[2],:]
        img_out = []
        for i in range(imgx.shape[-1]):
            tmpx = np.transpose(np.squeeze(imgx[::-1,::-1,i]))
            tmpy = np.transpose(np.squeeze(imgy[::-1,::-1,i]))
            tmpz = np.transpose(np.squeeze(imgz[::-1,:,i]))
            imgout = concat_planes(tmpx, tmpy, tmpz, axis=args.axis)
            # imgout = tmpz
            [vmin, vmax] = parse_list(args.vrange, 'float')
            vmin = vmin
            vmax = vmax*np.max(tmpz)
            imgout = scale2uint(imgout, [vmin,vmax])
            img_out.append(imgout)
    # 5. save the output
    if args.cmap == 'grey':
        img_out = np.concatenate(img_out,axis=1-args.axis)
        if args.filetype != 'mp4':
            io.imwrite(args.outname+'.png',img_out)
        else:
            io.mimsave(args.outname+'.mp4',img_out,macro_block_size=1)
import mat73
import numpy as np
import nibabel as nib
import argparse
import os


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Create masks for parallel computation')
    parser.add_argument('--ref', dest='ref_file', type=str, required=True)
    parser.add_argument('--out', dest='out_file', type=str, required=True)
    parser.add_argument('--ind', dest='mask index', type=int, required=True)
    parser.add_argument('--nparts', dest='mask parts', type=int, required=True)
    
    args = parser.parse_args()
    ref = nib.load(args.ref)
    im_size = ref.header.get_data_shape()
    mask = np.zeros(im_size[:3], dtype=bool)
    nelem = np.prod(mask.shape)
    mask = mask.reshape(-1,)
    sub_ele = np.ceil(nelem/args.nparts)
    idx = list(range((args.ind-1)*sub_ele, min(args.ind*sub_ele, nelem)))
    mask[idx] = 1
    mask = mask.reshape(mask.shape)

    # save mask i to out
    mask_nii = nib.Nifti1Image(mask, ref.affine)
    nib.save(mask_nii, args.out)
import mat73
import numpy as np
import nibabel as nib
import argparse
import os


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='partition masks for parallel computation')
    parser.add_argument('--in', dest='in_file', type=str, required=True)
    parser.add_argument('--out', dest='out_file', type=str, required=True)
    parser.add_argument('--ind', dest='ind', type=int, required=True)
    parser.add_argument('--nparts', dest='nparts', type=int, required=True)
    
    args = parser.parse_args()
    ref = nib.load(args.in_file)
    im_size = ref.header.get_data_shape()
    ref_img = ref.get_fdata()

    mask = np.zeros(ref_img.shape, dtype=bool)
    nelem = np.prod(mask.shape)
    mask = mask.reshape(-1,)
    sub_ele = int(np.ceil(nelem/args.nparts))
    idx = list(range((args.ind-1)*sub_ele, min(args.ind*sub_ele, nelem)))
    mask[idx] = 1
    mask = mask.reshape(ref_img.shape)

    out_img = ref_img * mask

    # save mask i to out
    out_nii = nib.Nifti1Image(out_img, ref.affine)
    nib.save(out_nii, args.out_file)
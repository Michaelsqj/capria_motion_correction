import numpy as np
import nibabel as nib
import os
import argparse
import mat73



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--fname', type=str, help='mat', required=True)
    parser.add_argument('--index', type=int, help='index', required=False)
    parser.add_argument('--ref', type=str, help='ref', required=True)
    parser.add_argument('--scaling', type=float, help='scaling', required=False, default=1e6)
    args = parser.parse_args()

    rd = mat73.loadmat(args.fname)['rd']
    basis = mat73.loadmat(args.fname)['basis']

    [sx, sy, sz, nk] = rd.shape
    print(rd.shape)
    [nt, nk] = basis.shape
    print(basis.shape)

    ref_nii = nib.load(args.ref)

    img = np.reshape(np.reshape(rd, (sx*sy*sz, nk)) @ basis.T, (sx, sy, sz, nt))

    img_nii = nib.Nifti1Image(np.abs(img)*args.scaling, ref_nii.affine)

    nib.save(img_nii, args.fname.replace('.mat', '.nii.gz'))
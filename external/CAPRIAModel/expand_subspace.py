import mat73
import numpy as np
import nibabel as nib
import argparse
import os


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Expand the subspace of the CAPRIA model')
    parser.add_argument('--in', dest='in_file', type=str, required=True)
    parser.add_argument('--out', dest='out_file', type=str, required=True)
    parser.add_argument('--mask', dest='mask_file', type=str, required=False, default=None)
    parser.add_argument('--ref', dest='ref_file', type=str, default='', required=False)

    args = parser.parse_args()
    in_file = args.in_file[:-len(".mat")]

    # os.makedirs(in_file+"_AngioFitting", exist_ok=True)
    dirpath = os.path.dirname(in_file)
    rd = mat73.loadmat(in_file+".mat")['rd']
    basis = mat73.loadmat(in_file+".mat")['basis']
    [sx, sy, sz, nk] = rd.shape
    [nt, nk] = basis.shape
    if args.ref_file == '':
        ref = nib.load(args.mask_file)
    else:
        ref = nib.load(args.ref_file)
    if args.mask_file is not None:
        # load mask
        mask = nib.load(args.mask_file).get_fdata()
        rd = rd * (mask.astype(bool)[..., np.newaxis])
    img = np.reshape(rd, (sx*sy*sz, nk)) @ basis.T
    img = np.reshape(img, (sx, sy, sz, nt))*1e7
    nii_img = nib.Nifti1Image(np.abs(img), ref.affine)
    # nib.save(nii_img, os.path.join(in_file+"_AngioFitting", 'data.nii.gz'))
    nib.save(nii_img, args.out_file)
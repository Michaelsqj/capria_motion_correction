import numpy as np
import nibabel as nib

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--infile', help='Path to input file.')
    parser.add_argument('--outfile', help='Path to output file.')
    args = parser.parse_args()

    nii_img = nib.load(args.infile)
    img = nii_img.get_fdata()
    new_img = img[::-1,::-1,...]
    new_nii_img = nib.Nifti1Image(new_img, nii_img.affine, nii_img.header)
    nib.save(new_nii_img, args.outfile)
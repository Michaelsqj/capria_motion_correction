import nibabel as nib
import mat73
import numpy as np
import scipy.io as sio



if __name__ == '__main__':
    """
    1. load sens mat file, save as real and imag nii files
    2. load real and imag nii files, save as sens mat file
    """
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--nii_real_file', help='Path to .mat file.')
    args = parser.parse_args()
    # combine sens_real_${ii}.nii.gz and sens_imag_${ii}.nii.gz -> sens_${ii}.mat
    sens_real = nib.load(args.nii_real_file).get_fdata()
    sens_imag = nib.load(args.nii_real_file.replace('real', 'imag')).get_fdata()
    sens = sens_real + 1j * sens_imag
    sio.savemat(args.nii_real_file.replace('_real', '').replace('.nii.gz','.mat'), {'sens': sens})
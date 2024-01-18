import nibabel as nib
import mat73
import numpy as np



if __name__ == '__main__':
    """
    1. load sens mat file, save as real and imag nii files
    2. load real and imag nii files, save as sens mat file
    """
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--mat_file', help='Path to .mat file.')
    parser.add_argument('--ref_file', help='Path to reference file.')
    args = parser.parse_args()
    
    sens = mat73.loadmat(args.mat_file)['sens']
    sens_real = np.real(sens)
    sens_imag = np.imag(sens)
    
    nii_ref = nib.load(args.ref_file)
    affine = nii_ref.affine
    header = nii_ref.header
    nib.save(nib.Nifti1Image(sens_real, affine, header), args.mat_file.replace('.mat', '_real.nii.gz'))
    nib.save(nib.Nifti1Image(sens_imag, affine, header), args.mat_file.replace('.mat', '_imag.nii.gz'))
import numpy as np
import scipy
import os
import nibabel as nib

def rotx(alpha):
    return np.array([[1, 0, 0],
                     [0, np.cos(alpha), -np.sin(alpha)],
                     [0, np.sin(alpha), np.cos(alpha)]])
def roty(alpha):
    return np.array([[np.cos(alpha), 0, np.sin(alpha)],
                     [0, 1, 0],
                     [-np.sin(alpha), 0, np.cos(alpha)]])
def rotz(alpha):
    return np.array([[np.cos(alpha), -np.sin(alpha), 0],
                     [np.sin(alpha), np.cos(alpha), 0],
                     [0, 0, 1]])

## load image from matlab
orig_img = nib.load('/vols/Scratch/qijia/moco_exp/expout/invivo_24_5_23_3/tmp2/test_nufft.nii.gz')
img = orig_img.get_fdata()
# get resolution of nifti image
res = orig_img.header['pixdim'][1:4]
resolution = res[0]
print(resolution)

## create tranformation
xform = np.zeros((4,4))
rotangle = np.array([0,0,-45])/180*np.pi
xform[:3,:3]=rotz(rotangle[0]).dot(roty(rotangle[1])).dot(rotx(rotangle[2]))
print(f"rotation matrix: {xform[:3,:3]}")

## add translation due to rotation around non-origin
img_shape = np.array(img.shape)
centre_of_mass = img_shape/2
rotation = xform[:3,:3]
displacement_due_to_rotation = rotation@centre_of_mass.T - centre_of_mass.T
correction_for_displacement_due_to_rotation = -displacement_due_to_rotation
displacement_to_apply = correction_for_displacement_due_to_rotation
print("displacement_to_apply: ", displacement_to_apply)

## apply transformation
img_rot = scipy.ndimage.affine_transform(img, xform[:3,:3], offset=xform[:3,3]+displacement_to_apply, output_shape=img.shape, order=1)

# ## save image
img_rot_nii = nib.Nifti1Image(img_rot, orig_img.affine)
nib.save(img_rot_nii, '/vols/Scratch/qijia/moco_exp/expout/invivo_24_5_23_3/tmp2/test_nufft_py.nii.gz')
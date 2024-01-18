import scipy.io as sio
import numpy as np
import sigpy as sp
import sigpy.mri as mr
import mat73
import nibabel as nib




if __name__ == '__main__':
    dev = sp.Device(0)
    datapath = '/vols/Data/okell/qijia/raw_data_6-11-23/meas_MID00139_FID35127_t1_mpr_ax_iso_PSN_anat1.mat'
    outpath ='/vols/Data/okell/qijia/raw_data_6-11-23/meas_MID00139_FID35127_t1_mpr_ax_iso_PSN_anat1_jsense'
    calib_ksp = mat73.loadmat(datapath)['m'].transpose(3,0,1,2)
    ref_img = nib.load('/vols/Data/okell/qijia/raw_data_6-11-23/meas_MID00139_FID35127_t1_mpr_ax_iso_PSN.nii.gz')

    # mps = mr.app.EspiritCalib(sp.to_device(calib_ksp,dev), device=dev, show_pbar=True,crop=0.7,thresh=0.03).run()
    mps = mr.app.JsenseRecon(sp.to_device(calib_ksp,dev), mps_ker_width=5, device=dev, show_pbar=True).run()
    mps = sp.to_device(mps,sp.cpu_device).transpose(1,2,3,0)
    nib.save(nib.Nifti1Image(np.abs(mps), ref_img.affine),outpath+'.nii.gz')
    sio.savemat(outpath+'.mat',{'sens':mps})
    print(mps.shape)
import os
import subprocess
import matplotlib.pyplot as plt
import numpy as np

rootdir = '/vols/Data/okell/qijia/perf_recon_23-3-23/meas_MID00168_FID09344_qijia_CV_VEPCASL_UTE_halfg_johnson_60_48x24_WE/'

img_name = 'recon_sense.nii.gz'
out_name = "recon_sense_brain.nii.gz"
par_name = "recon_sense_brain_mcf.par"

split_path = 'temp'
os.makedirs(os.path.join(rootdir, split_path), exist_ok=True)
strip_path = 'temp_brain'
os.makedirs(os.path.join(rootdir, strip_path), exist_ok=True)

# ------------------------------------------------------------------------
# split data
print("split data")
cmd = f"fslsplit {os.path.join(rootdir, img_name)} {os.path.join(rootdir,split_path)}/"
subprocess.run(cmd,shell=True)

# ------------------------------------------------------------------------
# synthstrip
print("synthstrip")
for fname in sorted(os.listdir(os.path.join(rootdir, split_path))):
    print(fname)
    cmd = f"synthstrip-singularity -i {os.path.join(rootdir, split_path, fname)} -o {os.path.join(rootdir, strip_path, fname)}"
    subprocess.run(cmd,shell=True)

# ------------------------------------------------------------------------
# merge
print("merge")
cmd = f"fslmerge -t {os.path.join(rootdir, out_name)} "
for fname in sorted(os.listdir(os.path.join(rootdir, strip_path))):
    print(fname)
    cmd = f"{cmd} {os.path.join(rootdir, strip_path, fname)}"

subprocess.run(cmd,shell=True)

# ------------------------------------------------------------------------
# mcflirt
cmd = f"mcflirt -in {os.path.join(rootdir, out_name)} -refvol 0 -plots -cost normmi"
subprocess.run(cmd,shell=True)

# ------------------------------------------------------------------------
# plot mcflirt
print("plot mcflirt")
a = []
with open(os.path.join(rootdir, par_name),'r') as f:
    lines = f.readlines()
    for line in lines:
        llist = line.split("  ")[:-1]
        llist = [float(i) for i in llist]
        print(llist)
        a.append(llist)
plots = np.array(a)
print(plots.shape)
plt.figure
plt.plot(range(plots.shape[0]),plots[:,:3])
plt.legend(["x","y","z"])
plt.title('translation')
plt.savefig("translation.png")
plt.figure
plt.plot(range(plots.shape[0]),plots[:,3:])
plt.legend(["x","y","z"])
plt.title('rotation')
plt.savefig("rotation.png")
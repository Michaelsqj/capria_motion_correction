import numpy as np
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import os

def plot_par2(param_list):
    fig, ax = plt.subplots(1,1, figsize=(15,5))
    for i, par in enumerate(param_list):
        ax.plot(par[:,0])
        ax.plot(par[:,1])
        ax.plot(par[:,2])
    ax.spines['bottom'].set_color('#dddddd')
    ax.spines['top'].set_color('#dddddd') 
    ax.spines['right'].set_color('#dddddd')
    ax.spines['left'].set_color('#dddddd')
    ax.tick_params(axis='both', which='major', labelsize=25, colors='#000000')
    fig.savefig('tmp.png')

def plot_par(param_list, parlabel_list):
    plt.figure()
    fig1, axes1 = plt.subplots(3,1, figsize=(15,15))
    fig2, axes2 = plt.subplots(3,1, figsize=(15,15))
    for i, (par, label) in enumerate(zip(param_list, parlabel_list)):
        if label =='Ground truth':
            col = cm.Greys(100)
            linestype='-'
        else:
            col = None
            linestype='--'
        
        axes1[0].plot(par[:,0]*180/np.pi, label=label, color=col, linestyle=linestype)
        # axes1[0].set_xlabel('Repeat Index', fontsize=15)
        axes1[0].set_ylabel('Rotation x (deg)', fontsize=25)
        axes1[0].tick_params(axis='both', which='major', labelsize=25)
        axes1[1].plot(par[:,1]*180/np.pi, label=label, color=col, linestyle=linestype)
        # axes1[1].set_xlabel('Repeat Index', fontsize=25)
        axes1[1].set_ylabel('Rotation y (deg)', fontsize=25)
        
        axes1[1].tick_params(axis='both', which='major', labelsize=25)
        axes1[2].plot(par[:,2]*180/np.pi, label=label, color=col, linestyle=linestype)
        axes1[2].set_xlabel('Repeat Index', fontsize=25)
        axes1[2].set_ylabel('Rotation z (deg)', fontsize=25)
        axes1[2].tick_params(axis='both', which='major', labelsize=25)

        axes2[0].plot(par[:,3], label=label, color=col, linestyle=linestype)
        # axes2[0].set_xlabel('Repeat Index', fontsize=25)
        axes2[0].set_ylabel('Translation x (mm)', fontsize=25)
        axes2[0].tick_params(axis='both', which='major', labelsize=25)

        axes2[1].plot(par[:,4], label=label, color=col, linestyle=linestype)
        # axes2[1].set_xlabel('Repeat Index', fontsize=25)
        axes2[1].set_ylabel('Translation y (mm)', fontsize=25)
        axes2[1].tick_params(axis='both', which='major', labelsize=25)

        axes2[2].plot(par[:,5], label=label, color=col, linestyle=linestype)
        axes2[2].set_xlabel('Repeat Index', fontsize=25)
        axes2[2].set_ylabel('Translation z (mm)', fontsize=25)
        axes2[2].tick_params(axis='both', which='major', labelsize=25)

    # axes1[0].legend()
    axes1[0].title.set_text('Rotation')
    axes1[0].title.set_fontsize(30)
    axes1[0].title.set_fontweight('bold')
    # axes1[1].legend()
    # axes1[2].legend()
    for ax in axes1:
        ax.plot([0, 100], [0, 0], color='k', linestyle='-')
        ax.set_xlim([0, 100])
        # ax.legend(prop=dict(size=20))
    # axes2[0].legend()
    axes2[0].title.set_text('Translation')
    axes2[0].title.set_fontsize(30)
    axes2[0].title.set_fontweight('bold')
    # axes2[1].legend()
    # axes2[2].legend()
    for ax in axes2:
        ax.plot([0, 100], [0, 0], color='k', linestyle='-')
        ax.set_xlim([0, 100])
        # ax.legend(prop=dict(size=20))
    # fig1.savefig('rotation.png')
    # fig2.savefig('translation.png')
    return fig1, fig2

if __name__ == '__main__':
    import os
    from glob import glob

    data_root = "/vols/Data/okell/qijia/"
    # search for folders containing subfolders named "scan_1", "scan_2", etc.
    dates = ['1-12-23', '1-12-23_2', '13-11-23', '15-11-23', '23-11-23', '28-11-23', '29-11-23', '30-11-23', '7-12-23']
    print(dates)

    for date in dates:
        for scan_id in os.listdir(f"{data_root}/perf_recon_{date}"):
            if scan_id.startswith("scan_"):
                scan_dir = os.path.join(data_root, f"perf_recon_{date}", scan_id)
                par_files = glob(os.path.join(scan_dir, "*.par"))
                
                if len(par_files) == 0:
                    continue
                par_file = par_files[0]
                fig1, fig2 = plot_par([np.loadtxt(par_file)], ['Ground truth'])
                fig1.savefig(f"plots/{date}_{scan_id}_rotation.png")
                fig2.savefig(f"plots/{date}_{scan_id}_translation.png")
                plt.close(fig1)
                plt.close(fig2)
                # for par_file in par_files:
                #     print(f"Processing {par_file}")
                #     par_data = np.loadtxt(par_file)
                #     plot_par([par_data[:, 0:6]])
                #     plt.savefig(f"{scan_id}_{date}.png")
                #     plt.close()
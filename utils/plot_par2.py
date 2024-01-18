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
    fig1.savefig('rotation.png')
    fig2.savefig('translation.png')


if __name__ == '__main__':
    parname_list = [
                    "/vols/Data/okell/qijia/perf_recon_27-10-23/subspace_2_combined_mcf.par",
                    # "/home/fs0/qijia/scratch/moco_exp/expout/for_abstract/tmp_subspace_brain_combined_mcf.par",
                    # "/home/fs0/qijia/scratch/moco_exp/expout/for_abstract/subspace_1_combined_mcf.par"
                    ]
    parlabel_list = ["Ground truth", "estimated","origin"]
    
    param_list = []
    for i, parname in enumerate(parname_list):
        param_list.append(np.loadtxt(parname))
    # plot_par(param_list[1:], parlabel_list[1:])
    # plot_par2([param_list[0][:,0:]*180/np.pi])
    plot_par2([param_list[0][:,3:]])
basename='meas_MID00143_FID02580_qijia_CV_VEPCASL_WE_fullg_johnson_45_256';
perfdir='/vols/Data/okell/qijia/perf_recon_8-12-23/';
angidir='/vols/Data/okell/qijia/recon_8-12-23/';

res_perf=2.343800;
%% load in sens mat
load([perfdir '/' basename '_sens1.mat'],'sens');
size(sens);
save_avw(real(sens),[perfdir '/' basename '_sens1_real'],'d',[1 1 1]*res_perf);
save_avw(imag(sens),[perfdir '/' basename '_sens1_imag'],'d',[1 1 1]*res_perf);

%% flirt register perf anat to angi anat
system(['flirt -in ' perfdir basename '_anat1tmp.nii.gz -ref ' angidir basename '_anat1tmp.nii.gz -omat '...
         angidir 'perf2angi_xfm -out ' basename '_anat1tmp_perfreg'])
%%
['applyxfm4D ' perfdir basename '_sens1_real ' angidir basename '_anat1tmp ' angidir basename '_sens1_real '...
       angidir 'perf2angi_xfm -singlematrix']
%%
['applyxfm4D ' perfdir basename '_sens1_imag ' angidir basename '_anat1tmp ' angidir basename '_sens1_imag '...
       angidir 'perf2angi_xfm -singlematrix']

%%
[img,~,scales,~,~]=read_avw([angidir basename '_sens1_real']);
sens_real = img;
[img,~,scales,~,~]=read_avw([angidir basename '_sens1_imag']);
sens_imag = img;

sens = sens_real + 1j*sens_imag;
save([angidir basename '_sens1.mat'], 'sens');
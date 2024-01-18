anatfname='/vols/Data/okell/qijia/perf_recon_12-10-23/meas_MID00023_FID32357_to_CV_VEPCASL_v0p6_qijia_36x49_176_164Hz_vFA_anat1.mat';
load(anatfname,'anat','m');
% compute scale factor, so that the maximum of the rss image has maximum
% value close to 1
scale_factor = prctile(anat,99,'all');
printf('scale factor is %f', scale_factor);     % 3.044884117523911e-06
km=bart('fft 7',m);
% espriit bart only support 2D estimation
sens = zeros(size(km));
% Cartesian kspace data
% Dimension	Usage
% 0	readout
% 1	phase-encoding dimension 1
% 2	phase-encoding dimension 2
% 3	receive channels
% 4	ESPIRiT maps
for ii = 1:size(km,3)
    sens(:,:,ii,:)=bart('ecalib -a -m1', km(:,:,ii,:));
end

% try to make sure the maximum value of coil sensitivity maps close
% to zero
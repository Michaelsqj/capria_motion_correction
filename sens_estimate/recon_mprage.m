cd ..
include_path()
cd sens_estimate

measID = '/vols/Data/okell/qijia/raw_data_12-10-23/meas_MID00021_FID32355_t1_mpr_ax_1_5mm_iso_PSN.dat'
outfname = '/vols/Data/okell/qijia/raw_data_12-10-23/mprage_t1_compressed_anat'

twix_obj = mapVBVD(measID,'ignoreSeg',true,'removeOS',false);
image=twix_obj{1,2}.image(:,:,:,:); % Readouts, Coils, Phases, Slices
image = permute(image,[1,3,4,2]);
NCoils = size(image,4);
% compress image
[U, S, V] = svd(reshape(image, [], NCoils), 'econ');
xfm = V(:, 1:8);
image = reshape(reshape(image, [], NCoils)*xfm, [size(image,1:3), 8]);
new_image = zeros(256,116,128,8);
new_image(end-199:end,:,:,:)=image;
image = new_image;

m = permute(crop(ifft3c(image), [128,116,128,8]), [2,1,3,4]);
m = m(:,end:-1:1,end:-1:1,:);
anat = squeeze(sum(abs(m).^2, 4).^0.5);

q = matfile(outfname, 'Writable', true);
q.m = m;
q.anat = anat;
q.xfm = xfm;
q.res = [1.718750, 1.718750, 1.700000];

save_avw(anat, outfname, 'd', [1.718750, 1.718750, 1.700000]);
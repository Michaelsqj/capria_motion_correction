function CreateDilatedVesselMask(DataPath, AngioVesMaskName,AngioDilVesMaskName,BMaskName)
    addpath('/home/fs0/qijia/code/CAPRIAModel')
    % First average the CFA and VFA data sets to be fair
    % clear Data
    % Data(:,:,:,:,1) = ra('../CAPRIA_Recon/CFA_Angio/resS.nii.gz');
    % Data(:,:,:,:,2) = ra('../CAPRIA_Recon/VFA_Angio/resS.nii.gz');
    % Data = mean(Data,5);
    [img,~,scales,~,~] = read_avw(DataPath);
    Data = img;
    % Read in the brain mask
    BMask = logical(ra(BMaskName));

    % Average across frames up to a maximum where angio
    % signal data is no longer present and brain mask
    MaxFrameNo = 6;
    Data = mean(Data(:,:,:,1:MaxFrameNo),4).*BMask;

    % Calculate a mask based on a fraction of a percentile
    PrcTl = 99.9; Frac = 0.7;
    Threshold = prctile(Data(:),PrcTl) * Frac;

    % Create the vessel mask
    VesselMask = abs(Data) >= Threshold;

    % Save out
    save_avw(VesselMask,AngioVesMaskName,'f',[1 1 1 1]);
    tosystem(['fslcpgeom ' BMaskName ' ' AngioVesMaskName ' -d'])

    % Create a dilated mask - this gave ~10% of voxels in the dilated mask
    % also present in the signal mask in initial testing
    tosystem(['fslmaths ' AngioVesMaskName ' -kernel sphere 3.5 -dilF ' AngioDilVesMaskName]);

end
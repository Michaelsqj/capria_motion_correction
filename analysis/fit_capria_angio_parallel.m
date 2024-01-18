function fit_capria_angio_parallel(fpath, p, isprocessed)
    % CAPRIA_MODELFIT_PARALLEL(fpath, prot_type, thresh, end_early)
    %   fpath: path to the data
    %   p: parameters
    %      prot_type
    %
    %   This function is used to fit the CAPRIA model to the data
    %   to do it parallel
    %   the data should be in the following structure
    %   ｜--dynamic angiogram data
    %   ｜--data processing folder: xxx_AngioFitting
    %   ｜----data.nii.gz:  data scaled to maximum value closer to 1
    %   ｜----mask.nii.gz:  mask for the data
    %   ｜----output_i
    %   ｜------mask_i
    %   ｜------fabber_out_latest

    %   1. create mask
    %   2. fit the model
    %   3. convert mean_disp1 and mean_disp2 to mean_disp_s and mean_disp_p
    %   4. save the results to the output_i folder
    %   5. merge the results to the data processing folder
    %   6. delete the output_i folder

    addpath('/home/fs0/qijia/code/CAPRIAModel')
    
    % 1. preprocess data
    [dirname,name,ext] = fileparts(fpath)
    name = char(name);
    name = name(1:end-length('.nii'));
    ext = ".nii.gz";
    fname = name + ext
    outpath = char(name+"_AngioFitting")
    mkdir([char(dirname) '/' char(outpath)])
    cd([char(dirname) '/' char(outpath)])

    if nargin==3 && ~isprocessed     % else just directly use the mask_clusters_bin
        % 1.1 Rescale the data to prevent premature fitting stops
        tosystem(['fslmaths ../', char(fname), ' -mul 1e10 data'])

        % 1.2 Generate a mask
        tosystem(['fslmaths data -Tmax -thr ',ns(p.thresh1),' -bin mask']) % threshold default around 30
        tosystem(['cluster --in=mask --thresh=' ns(p.thresh2) ' -o mask_clusters'])
        [~,tmp]=builtin('system','fslstats mask_clusters -R');
        maxI = split(tmp,' ');
        maxI = str2num(maxI{2});
        thr = ns(maxI - 1);
        if isfield(p, thresh3)
            thr = ns(p.thresh3);
        end
        tosystem(['fslmaths mask_clusters -thr ' thr ' -bin mask_clusters_bin'])
    % elseif ~isfile('mask_clusters_bin.nii.gz')
    %     error('mask_clusters_bin.nii.gz not found')
    end

    %% Set up some example parameters
    tau = 1.8;
    switch p.prot_type
        case 0  % cone or radial with matched TR
            TR = 14.7e-3; Nsegs = 12; Nphases = 12; VFAParams = [3 12];
        case 1  % radial previous protocol
            TR = 9.8e-3;  Nsegs=18; Nphases = 12; VFAParams = [2 9];
        case 2  % water excitation cone
            TR = 16e-3;  Nsegs=12; Nphases = 12; VFAParams = [3 12];
    end

    % Calculate the time of the start of imaging, accounting for spoilers etc. 
    t0 = tau+2e-3+10e-3+11e-3+10e-3+2e-3; 

    % Calculate a time array - note this must be separated by TR for the
    % following model to work correctly
    t = t0:TR:(t0+(Nsegs*Nphases-1)*TR);
    [status,cmdout] = system(['fslinfo ' char(fpath)]); cmdouts = strsplit(cmdout,'\s','DelimiterType','RegularExpression');
    Nt = str2double(cmdouts{1,10})
    Nsegs = Nsegs*Nphases / Nt;
    Nphases = Nt;
    for ii = 1:Nphases
        Idx = (t >= t0+((ii-1)*Nsegs)*TR) & (t < t0+ii*Nsegs*TR);
        tAv(ii) = mean(t(Idx));
    end
    
    Alpha = CalcCAPRIAFAs('quadratic',VFAParams,t,t0);
    % T1 of blood
    T1b = get_relaxation_times(3,'blood')/1000; 

    %% Parallel fitting
    fid0 = fopen('parallel_script.sh','w');
    FSLSUBCMD=['fsl_sub -m n -l logs -q short.q '];
    % 1. create the output_i folder 
    fid = fopen('create_output_script','w')
    for i=1:100
        SUBCMD=['mkdir output_' ns(i)];
        fprintf(fid, '%s\n', SUBCMD);
    end
    fclose(fid);
    fprintf(fid0, '%s\n', ['ID=$(' FSLSUBCMD ' -t create_output_script)']);


    % 2. multiply mask_i with mask_clusters_bin
    mask_path='/vols/Data/okell/qijia/test_fabber/masks/mask_'
    fid = fopen('multiply_mask_script','w');
    for i=1:100
        SUBCMD=['fslmaths mask_clusters_bin -mul ' mask_path ns(i) ' output_' ns(i) '/mask'];
        fprintf(fid, '%s\n', SUBCMD);
    end
    fclose(fid);
    fprintf(fid0, '%s\n', ['ID=$(' FSLSUBCMD ' -j $ID -t multiply_mask_script)']);

    % 3. Run the fitting
    fid = fopen('fitting_script','w');
    for i=1:100
        fabcmd = '/home/fs0/qijia/code/fsldev/bin/fabber_asl';
        fabcmd = [fabcmd ' --data=data.nii.gz --mask=output_' ns(i) '/mask.nii.gz'];
        fabcmd = [fabcmd ' --model=aslrest --disp=gamma --method=vb --inferdisp']; 
        fabcmd = [fabcmd ' --batart=0.5']; % Try earlier BAT prior for arterial component
        fabcmd = [fabcmd ' --noise=white --allow-bad-voxels --max-iterations=20 --convergence=trialmode --max-trials=10'];
        fabcmd = [fabcmd ' --save-mean --save-mvn --save-std --save-model-fit --save-residuals'];
        for jj = 1:length(tAv)
            fabcmd = [fabcmd ' --ti' ns(jj) '=' ns(tAv(jj)) ' --rpt' ns(jj) '=1']; 
        end
        fabcmd = [fabcmd ' --tau=' ns(tau) ' --casl --slicedt=0.0 --t1=1.3 --t1b=' ns(T1b) ' --bat=1.3 --batsd=10.0 --incbat --inferbat --incart --inferart '];
        fabcmd = [fabcmd ' --capria --capriafa1=' ns(VFAParams(1)) ' --capriafa2=' ns(VFAParams(2)) ' --capriatr=' ns(TR)];
        fabcmd1 = [fabcmd ' --output=output_' ns(i) '/fabber_out'];
        fprintf(fid, '%s\n', fabcmd1);
    end
    fclose(fid);
    fprintf(fid0, '%s\n', ['ID=$(' FSLSUBCMD ' -j $ID -t fitting_script)']);

    % 4. Merge outputs
    filenames = {'mean_deltblood', 'mean_disp1', 'mean_disp2', 'mean_fblood'}
    fid = fopen('merge_script','w');
    mkdir('fabber_out')
    for i=1:length(filenames)
        CMD=['fslmaths output_1/fabber_out/' filenames{i}];
        for j=2:100
            CMD = [CMD ' -add output_' ns(j) '/fabber_out/' filenames{i}];
        end
        CMD = [CMD ' fabber_out/' filenames{i}];
        fprintf(fid, '%s\n', CMD);
    end
    fclose(fid);
    fprintf(fid0, '%s\n', ['ID=$(' FSLSUBCMD ' -j $ID -t merge_script)']);
    
    % 5. Convert outputs
    CMD=['fslmaths fabber_out/mean_disp1 -exp fabber_out/mean_disp_s"'];
    fprintf(fid0, '%s\n', ['ID=$(' FSLSUBCMD ' -j $ID "' CMD ')']);
    CMD=['fslmaths fabber_out/mean_disp2 -exp -uthr 10 -div fabber_out/mean_disp_s fabber_out/mean_disp_p"'];
    fprintf(fid0, '%s\n', ['ID=$(' FSLSUBCMD ' -j $ID "' CMD ')']);

    % 6. Delete the output_i folder
    fid = fopen('delete_script','w');
    for i=1:100
        CMD=['rm -r output_' ns(i)];
        fprintf(fid, '%s\n', CMD);
    end
    fclose(fid);
    fprintf(fid0, '%s\n', ['ID=$(' FSLSUBCMD ' -j $ID -t delete_script)']);

    fclose(fid0);
    % tosystem('bash parallel_script.sh')
end
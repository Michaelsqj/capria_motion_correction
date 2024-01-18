function par_res = calc_res_par(PAR_IN_FILE, cog_in, MAT_REG_DIR, REF_VOL)
    % calculate residual motion after registration
    % par_in: Nx6
    % cog_in: 3x1
    % xfm_reg: N x 4 x 4
    % 1. calculate xfm_in using par_in  and cog_in
    par_in = load(PAR_IN_FILE);
    tmp = strsplit(PAR_IN_FILE, '/');
    PAR_IN_FNAME = tmp{end};
    tmp = strsplit(MAT_REG_DIR, '/');
    MAT_REG_DIRNAME = tmp{end};
    [dirname fname ext]=fileparts(MAT_REG_DIR);
    assert(size(par_in, 2) == 6, 'par_in should be Nx6');
    assert(size(cog_in, 1) == 3, 'cog_in should be 3x1');
    N = size(par_in, 1);
    MAT_in = zeros(N, 4, 4);
    for ii = 1:N
        MAT_in(ii, :, :) = convert_params2MAT(par_in(ii, :)', cog_in);
    end

    [MAT_in] = invert_mat(MAT_in);
    % 2. calculate xfm_res concatenating xfm_in and xfm_reg
    combined_path = [dirname '/' PAR_IN_FNAME '.' MAT_REG_DIRNAME '.mat'];
    MAT_reg = load_matrices(MAT_REG_DIR);
    for ii = 1:N
        MAT_res(ii, :, :) = squeeze(MAT_reg(ii, :, :)) * squeeze(MAT_in(ii, :, :));
    end
    write_matrices(MAT_res, combined_path);
    % 3. using avscale to calculate residual par corresponding to cog_in
    for ii = 1:N
        fname = sprintf('%s/MAT_%04d', combined_path, ii-1);
        par = parse_avscale(fname, REF_VOL);
        par_res(ii, :) = par;
    end
    % 4. write residual par to file
    par_res_path = [dirname '/' PAR_IN_FNAME '.' MAT_REG_DIRNAME '.res.par'];
    fid = fopen(par_res_path, 'w');
    for ii = 1:N
        fprintf(fid, '%f  %f  %f  %f  %f  %f\n', par_res(ii, :));
    end
end
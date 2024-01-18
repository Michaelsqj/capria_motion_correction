function write_matrices(MAT, DIRNAME)
    % MAT: Nx4x4
    % output name : DIRNAME/MAT_0000, DIRNAME/MAT_0001, ...
    mkdir(DIRNAME);
    for i = 1:size(MAT, 1)
        filename = sprintf('%s/MAT_%04d', DIRNAME, i-1);
        fid = fopen(filename, 'w');
        fprintf(fid, '%f  %f  %f  %f\n', squeeze(MAT(i, 1, :)));
        fprintf(fid, '%f  %f  %f  %f\n', squeeze(MAT(i, 2, :)));
        fprintf(fid, '%f  %f  %f  %f\n', squeeze(MAT(i, 3, :)));
        fprintf(fid, '%f  %f  %f  %f\n', squeeze(MAT(i, 4, :)));
        fclose(fid);
    end
end
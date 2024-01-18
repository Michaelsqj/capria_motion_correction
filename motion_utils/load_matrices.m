function MAT = load_matrices(MAT_DIR)
    % load transformation matrcies from the directory in format MAT_0000, MAT_0001, ...
    % calculate the number of files under the directory
    files = dir(MAT_DIR);
    num_files = length(files) - 2; % remove . and ..
    MAT = zeros(num_files, 4, 4);
    for ii = 1:num_files
        fname = sprintf('%s/MAT_%04d', MAT_DIR, ii-1);
        MAT(ii,:,:) = load(fname);
%         fprintf('Loading %s\n', fname);
    end
    fprintf('Done loading %d matrcies\n', num_files);
end
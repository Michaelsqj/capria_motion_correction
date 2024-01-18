function [mat_a2c] = concat_mat(mat_b2c, mat_a2b)
    mat_a2c = zeros(size(mat_b2c));
    for ii = 1:size(mat_b2c,1)
        mat_a2c(ii,:,:) = squeeze(mat_b2c(ii,:,:)) * squeeze(mat_a2b(ii,:,:));
    end
end
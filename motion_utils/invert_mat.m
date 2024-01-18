function [invmats] = invert_mat(mats)
    % mats : [N, 4, 4]
    assert(size(mats, 2) == 4 && size(mats, 3) == 4);
    invmats = zeros(size(mats));
    for ii = 1:size(mats, 1)
        R = squeeze(mats(ii, 1:3, 1:3));
        newR = R';
        invmats(ii, 1:3, 1:3) = newR;
        invmats(ii, 1:3, 4) = -newR * reshape(mats(ii, 1:3, 4), 3, 1);
        invmats(ii, 4, 4) = 1;
    end

end
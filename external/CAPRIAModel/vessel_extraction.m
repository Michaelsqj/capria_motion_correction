function vessel_extraction(fpath, startpoint, maxlength)
    % find out a path on the skeleton image from a startpoint to maxlength
    [img, ~, scales, ~, ~] = read_avw(fpath);
    total_length = 0;
    pts=reshape(startpoint,1,3);
    while total_length < maxlength
        % find the next point
        [nextpoint] = find_next_point(img, startpoint, pts);
        % calculate the length
        if isempty(nextpoint)
            break
        end
        total_length = total_length + 1;
        pts(total_length,:) = nextpoint;
        % update the startpoint
        startpoint = nextpoint;
        printf('total length: %d\n', total_length);
        printf('next point: %d, %d, %d\n', nextpoint(1), nextpoint(2), nextpoint(3));
    end
end

function nextpoint = find_next_point(img, startpoint, pts)
    % find the next point on the skeleton image
    % find in the 3x3x3 cube, if any neighboring points 
    % are 1, then return the point
    % if no neighboring points are 1, then return  []
    % if more than one neighboring points are 1, then return the point 
    % with largest x, y, z coordinates on three directions
    nextpoint = [];
    for k = 1:-1:-1
        for j = 1:-1:-1
            for i = 1:-1:-1
                % if the point is outside the image, then skip
                if startpoint(1) + i < 1 || startpoint(1) + i > size(img, 1) || ...
                   startpoint(2) + j < 1 || startpoint(2) + j > size(img, 2) || ...
                   startpoint(3) + k < 1 || startpoint(3) + k > size(img, 3)
                    continue
                end
                if i == 0 && j == 0 && k == 0
                    continue
                elseif img(startpoint(1) + i, startpoint(2) + j, startpoint(3) + k) == 1
                    nextpoint = [startpoint(1) + i, startpoint(2) + j, startpoint(3) + k];
                    return
                end
            end
        end
    end
end
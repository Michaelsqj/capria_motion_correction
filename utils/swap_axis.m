function [tmp] = swap_axis(kspace, axis1, axis2)
    tmp = kspace;
    tmp(:,axis1) = kspace(:,axis2);
    tmp(:,axis2) = kspace(:,axis1);
end
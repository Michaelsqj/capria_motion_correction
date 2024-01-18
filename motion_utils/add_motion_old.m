function [new_kspace, new_image] = add_motion_old(kspace, image, thetas, translations)
    % kspace: [NCols*NLines, Nt, 3], 1/cm, -kmax~ kmax
    % image: [NCols*NLines, Nt,NCoils]
    % thetas: [Nt,3], rotation along x-axis, y-axis, z-axis
    % translations: [Nt,3], translation in cm
    
    [~, Nt, ~] = size(kspace);
    assert((size(image,2)==Nt) && (size(thetas,1)==Nt) && (size(translations,1)==Nt))
    
    new_kspace = zeros(size(kspace));
    new_image  = zeros(size(image));

    for t = 1:Nt
        theta = thetas(t,:);
        translation = translations(t,:);
        Rx=[1, 0, 0;...
            0, cosd(theta(1)), -sind(theta(1));...
            0, sind(theta(1)), cosd(theta(1))];

        Ry=[cosd(theta(2)), 0, sind(theta(2));...
            0, 1, 0;...
            -sind(theta(2)), 0, cosd(theta(2))];

        Rz=[cosd(theta(3)), -sind(theta(3)), 0;...
            sind(theta(3)), cosd(theta(3)), 0;...
            0, 0, 1];

        R = (Rz*Ry*Rx)';

        new_kspace(:,t,:) = squeeze(kspace(:,t,:)) * R;
        new_image(:,t,:) = exp(1j.*2*pi*sum(kspace(:,t,:).*reshape(translation, 1,1,3),3)) .* image(:,t,:);
    end

end




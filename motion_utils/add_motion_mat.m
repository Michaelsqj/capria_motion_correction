function [new_kspace, new_image] = add_motion_mat(kspace, image, mats, resolution, img_shape)
    % kspace: [NCols*NLines, Nt, 3], 1/cm, -kmax~ kmax
    % image: [NCols*NLines, Nt,NCoils]
    % mats: [Nt, 4, 4], Rotation mat + 3 translation
    
    [~, Nt, ~] = size(kspace);
    assert((size(image,2)==Nt) && (size(mats,1)==Nt))
    
    new_kspace = zeros(size(kspace));
    new_image  = zeros(size(image));
    resolution = resolution * 0.1; % mm -> cm conversion

    for t = 1:Nt
        xform = squeeze(mats(t,:,:));

        rotation = xform(1:3,1:3)';
        translation = xform(1:3,4);

        tmpk = squeeze(kspace(:,t,:));
        tmpk = tmpk * rotation;
        new_kspace(:,t,:) = tmpk;

        tmpt = translation;
        translation = tmpt * 0.1;   % mm -> cm conversion

        centre_of_mass = resolution*(img_shape./2-1);
        displacement_due_to_rotation = (rotation*(centre_of_mass') - centre_of_mass');
        correction_for_displacement_due_to_rotation = displacement_due_to_rotation;
        displacement_to_apply = -translation + correction_for_displacement_due_to_rotation;

        new_image(:,t,:) = exp(1j.*2*pi*sum(kspace(:,t,:).*reshape(displacement_to_apply, 1,1,3),3)) .* image(:,t,:);
%         new_image(:,t,:) = exp(1j.*2*pi*sum(new_kspace(:,t,:).*reshape(displacement_to_apply, 1,1,3),3)) .* image(:,t,:);
    end

end
function [new_kspace, new_image] = add_motion_mat2(kspace, image, mats, resolution, img_shape)
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

        rotation = xform(1:3,1:3);
        translation = xform(1:3,4);

        tmpk = squeeze(kspace(:,t,:));
        tmpk = (rotation * tmpk')';
        new_kspace(:,t,:) = tmpk;

        tmpt = translation;
        translation = tmpt * 0.1;   % mm -> cm conversion

        centre_of_mass = resolution*(img_shape./2);
        correction_for_displacement_due_to_rotation = -(centre_of_mass' - rotation*(centre_of_mass'));
%         correction_for_displacement_due_to_rotation = [0, 0, 0];
        displacement_to_apply = -(reshape(translation,3,1) + reshape(correction_for_displacement_due_to_rotation,3,1));

        % new_image(:,t,:) = exp(1j.*2*pi*sum(kspace(:,t,:).*reshape(displacement_to_apply, 1,1,3),3)) .* image(:,t,:);
        new_image(:,t,:) = exp(1j.*2*pi*sum(new_kspace(:,t,:).*reshape(displacement_to_apply, 1,1,3),3)) .* image(:,t,:);
    end

end
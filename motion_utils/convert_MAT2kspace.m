function [new_kspace, new_image] = convert_MAT2kspace(kspace, image, MAT, im_size, resolution)
    % Convert MAT exported by McFLIRT to transform in k-space
    % so the reconstructed image is aligned with image transformed using McFLIRT
    % kspace: [Npts, 3], 1/cm, -kmax~ kmax
    % image: [Npts, Nc]
    % MAT: [4, 4]
    % resolution: scalar, cm
    rotation = MAT(1:3,1:3)';
    translation = MAT(1:3,4);

    new_kspace = kspace * rotation;

    translation = translation * 0.1;   % mm -> cm conversion

    centre_of_mass = resolution*(im_size./2);
    displacement_due_to_rotation = (rotation*(centre_of_mass') - centre_of_mass');
    correction_for_displacement_due_to_rotation = displacement_due_to_rotation;
    displacement_to_apply = -translation + correction_for_displacement_due_to_rotation;

    new_image = exp(1j.*2*pi*sum(kspace.*reshape(displacement_to_apply, 1,1,3),3)) .* image;

end
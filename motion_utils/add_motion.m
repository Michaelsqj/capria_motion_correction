function [new_kspace, new_image ] = add_motion(kspace, image, p)
    % image: NCols, Nsegs*NPhases, Nshots, Navgs, NCoils    1/cm, -kmax~ kmax
    % kspace: NCols, Nsegs*NPhases, Nshots, Navgs, 3
    % motion_par: Navgs*Nshots, 6
    % resolution: mm

    if isfield(p, 'cog') && isfield(p, 'motion_par')
        cog = p.cog;
        motion_par = load(p.motion_par);
        if isfield(p, 'scale_motion')
            motion_par = motion_par * p.scale_motion;
        end
        assert(size(motion_par, 2)==6);
    else
        new_kspace = kspace;
        new_image = image;
        return
    end
    

    Nshots = size(kspace, 3);
    Navgs = size(kspace, 4);
    NCoils = size(image, 5);
    Nt = size(image, 2);
    NCols = size(image, 1);
    assert(size(kspace, 1)== size(image, 1) && size(kspace, 2)== size(image, 2) ...
           && size(kspace, 3)== size(image, 3) && size(kspace, 4)== size(image, 4))

    % 0. align motion_par to the image dimension order
    motion_par = permute(reshape(motion_par, [Navgs, Nshots, 6]), [2,1,3]);
    motion_par = reshape(motion_par, [], 6);

    % 1. add perturbation to each segments in each repeat
    % if isfield(p, 'perturb_par') && p.perturb_par
    %     motion_par = repmat(reshape(motion_par, [1, Nshots, Navgs,6]), [Nt, 1, 1, 1]);
    %     perturb_strength = linspace(1-p.perturb_par, 1+p.perturb_par, Nt);
    %     motion_par = motion_par .* reshape(perturb_strength, [], 1);
    % else
    %     motion_par = repmat(reshape(motion_par, [1, Nshots, Navgs, 6]), [Nt, 1, 1, 1]);
    % end
    % 2. convert the motion_par to matrix
    % motion_par = reshape(motion_par, [], 6);
    mats = zeros(size(motion_par, 1), 4, 4 );
    for ii = 1:size(motion_par, 1)
        mats(ii,:,:) = convert_params2MAT(reshape(motion_par(ii,:),[],1), reshape(cog,[],1));
        % 3. invert the motion_par matrix or not
        if isfield(p, 'invert_mat') && p.invert_mat
            mats(ii,:,:) = invert_mat(mats(ii,:,:));
        end
    end


    % 4. apply the transformation matrix to kspace and image
    [new_kspace, new_image] = add_motion_mat2(reshape(kspace,NCols*Nt,Nshots*Navgs,3),reshape( image,NCols*Nt,Nshots*Navgs, NCoils),mats, p.res, p.recon_shape);
    % 5. reshape the kspace and image
    new_kspace = reshape(new_kspace, NCols, Nt, Nshots, Navgs, 3);
    new_image = reshape(new_image, NCols, Nt, Nshots, Navgs, NCoils);
end
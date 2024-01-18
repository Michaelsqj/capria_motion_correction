function [new_motion_params] = change_cog_par(par, old_cog, new_cog)
    % The translation of par is related to the old cog, this function
    % changes the translation so that it is related to the new cog.
    % par: 6x1 vector, [N, 6]
    new_motion_params = zeros(size(par));
    N = size(par,1);
    for ii = 1:N
        rot_params = par(ii,1:3)/pi*180;
        rotation = rotz(rot_params(3))*roty(rot_params(2))*rotx(rot_params(1));
        rotation = rotation';
        new_tnsl = (rotation*(new_cog-old_cog)-(new_cog-old_cog)) + par(ii,4:6)';
        new_motion_params(ii,1:3) = rot_params/180*pi;
        new_motion_params(ii,4:6) = new_tnsl;
    end
end
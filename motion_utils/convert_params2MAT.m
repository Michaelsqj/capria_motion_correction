function [MAT]=convert_params2MAT(motion_params, cog)
    % convert 6 parameters output by McFLIRT -plots option to 
    % 4x4 MAT output by McFLIRT -mats option
    % motion_params: [6,1]
    % cog: [3,1], center of gravity of the reference image when using 
    %       Flirt or McFLIRT 
    %       Calculation steps:      
    %       1. fslstats <refvol> -C  output in voxeldim
    %       2. multiply with pixdim to convert to [cm]
    motion_params(1:3) = motion_params(1:3)/pi*180;
    rotation = rotz(motion_params(3))*roty(motion_params(2))*rotx(motion_params(1));
    rotation = rotation';
    translation = -(rotation*cog-cog) + motion_params(4:6);
    MAT = [rotation, translation; 0,0,0,1];
end
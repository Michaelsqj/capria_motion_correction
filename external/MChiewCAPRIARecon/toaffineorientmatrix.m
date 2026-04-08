% This function creates a nifti header with the correct scanner orientation
% information

% Mtx converts voxel coords into x,y,z coords.  Can set qform and sform to
% be the same

% fslorient -setsform <m11 m12 ... m44>  filename
% fslorient -copysform2qform   filename

function Mtx = toaffineorientmatrix(scales, dims, CentreSliceOffset)

% Ensure vectors are column vectors
scales = scales(:); dims = dims(:); 

% Flip x and y coordinates of central slice position to match Nifti
% conversion
CentreSliceOffset = CentreSliceOffset(:) .* [-1; -1; 1];

% After recon, FOV centre point is assumed to be at ceil((dims+1)/2)
% using Matlab indexing. For FSL/Nifti indexing, we start from zero, so the
% centre of the FOV is at ceil((dims-1)/2). However, both the row index
% (which becomes y) and the slice index (z) are flipped in the Nifti, so
% indexing starts from the opposite end, so we need to use floor instead.
% e.g. Matlab idx: [1 2 3 *4* 5 6]
% FSL idx:         [0 1 2 *3* 4 5]
% FSL idx flipped: [5 4 3 *2* 1 0]
% For an odd dimension size:
% Matlab idx:      [1 2 *3* 4 5]
% FSL idx:         [0 1 *2* 3 4]
% FSL idx flipped: [4 3 *2* 1 0]
VoxCentreIdx = [ceil((dims(1)-1)/2); floor((dims(2)-1)/2); floor((dims(3)-1)/2)];

% We want Mtx * VoxCentreIdx = CentreSliceOffset
% So use Mtx'*(dims-1)/2 = X -> Mtx(:,4) = CentreSliceOffset - X;
  MtxP = [-scales(1) 0 0 0; ...
          0  scales(2) 0 0; ...
          0 0  scales(3) 0; ...
          0 0 0 1];
  
  %X = MtxP * [ceil((dims(1:3)-1)/2); 1];
  X = MtxP * [VoxCentreIdx; 1];
  
  Mtx = MtxP;
  
  Mtx(:,4) = [CentreSliceOffset - X(1:3); 1];
  
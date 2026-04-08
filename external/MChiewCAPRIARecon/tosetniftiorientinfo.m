% This function creates a nifti header with the correct scanner orientation
% information

% Mtx converts voxel coords into x,y,z coords.  Can set qform and sform to
% be the same

% fslorient -setsform <m11 m12 ... m44>  filename
% fslorient -copysform2qform   filename

function Mtx = tosetniftiorientinfo(Fname, scales, dims, CentreSliceOffset)

  % Get the affine matrix
  Mtx = toaffineorientmatrix(scales,dims,CentreSliceOffset);
  
  % Convert to correct format
  Mtx = Mtx';
  Mtx = Mtx(:)';
  
  % Set the qform and sform matrices
  cmd = ['fslorient -setsformcode 1 ' Fname];
  disp(cmd); system(cmd);
  cmd = ['fslorient -setsform ' ns(Mtx) ' ' Fname];
  disp(cmd); system(cmd);
  cmd = ['fslorient -copysform2qform ' Fname];
  disp(cmd); system(cmd);
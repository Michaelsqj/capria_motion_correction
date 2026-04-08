% This function rotates a dynamic angio image stack to present it in the
% usual orientation.  K may be set to -1 to rotate in the opposite
% direction
%
% function Out = RotateDynAngioData(In, K);

function Out = RotateDynAngioData(In, K)

  % Default is to rotate anti-clockwise (translates from .nii.gz to
  % matlab format)
  if nargin == 1
    K = 1;
  end
  
  for i = 1:size(In,3)
    for j = 1:size(In,4)
		for k = 1:size(In,5)
			for l = 1:size(In,6)
				Out(:,:,i,j,k,l) = rot90(In(:,:,i,j,k,l), K);
			end
		end
    end
  end
  
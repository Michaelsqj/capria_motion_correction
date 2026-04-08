% This function concatenates vascular components and slices for display
% purposes

function CatIm = CatComps(ImStack)
  
  CatIm = [];
  for CompNo = 1:size(ImStack,4)
    CatIm = [CatIm; CatSlices(ImStack(:,:,:,CompNo))];
  end

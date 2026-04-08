% This function interpolates a set of 2D slices by zero-padding in
% k-space by the given factor and then transforming back into real space
%
% function out = InterpolateViaKSpace(In, ExpFactor)

function out = InterpolateViaKSpace(In, ExpFactor, ApplyRollOffFilter, NoPixelsForFilter)
  
  % If no factor given, assume 2x expansion factor
  if nargin < 2; ExpFactor = 2; end
  if nargin < 3; ApplyRollOffFilter = false; end
  if nargin < 4; NoPixelsForFilter = 10; end
  
  % Calculate the size of the output image, rounding to the nearest
  % factor of two
  N = size(In);
  Nout = round( N(1:2) * ExpFactor / 2) * 2;
  
  % Initialise output
  out = zeros([Nout size(In,3) size(In,4)]);
  
  % Prep the roll off filter if used
  if ApplyRollOffFilter
    Nf = round(NoPixelsForFilter/2);
    Sz = size(In);
    Filter = zeros(Sz(1:2));
    RowIdx = Nf+1:Sz(1)-Nf;
    ColIdx = Nf+1:Sz(2)-Nf;
    Filter(RowIdx,ColIdx) = 1;
    
    % Smooth
    Filter = smooth2a(Filter,Nf);
  end
            
            
  % Perform separately for each time point, slice and cycle
  for i = 1:size(In,3)
    
    for j = 1:size(In,4)
      
        for k = 1:size(In,5)
            % Calculate the fft and shift the centre of k-space to the centre
            FTSlice = fftshift( fft2( In(:,:,i,j,k) ) );
            
            % Apply the rolloff filter if necessary
            if ApplyRollOffFilter
               FTSlice = FTSlice.*Filter;
            end
            
            % Pad with zeros
            FTPad = zeros(Nout);
            StartIdx = (Nout - N(1:2))/2 + 1;
            EndIdx = StartIdx + N(1:2) - 1;
            FTPad( StartIdx(1):EndIdx(1), StartIdx(2):EndIdx(2) ) = FTSlice;
            
            % Inverse transform into the output
            out(:,:,i,j,k) = ifft2( ifftshift( FTPad ) );
            
        end
    end
    
  end
  
  % Normalise the output magnitude
  out = out * abs(mean(In(:))) / abs(mean(out(:)));
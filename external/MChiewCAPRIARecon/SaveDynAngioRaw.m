% This function saves raw dynamic angio images into an identical format to
% those straight off the scanner.
%
% [OutMagFName OutPhFName] = SaveDynAngioRaw(RawIms, OutFileName, Scales,
% Interp,  CentreSliceOffset, CopyGeomFromFName)

function [OutMagFName OutPhFName] = SaveDynAngioRaw(RawIms, OutFileName, Scales, Interp,  CentreSliceOffset, CopyGeomFromFName, JustRotate)
  
  % Deal with optional arguments
  if (nargin < 3) || (sum(isnan(Scales))>0); Scales = [1 1 1 1]; end
  if nargin < 4; Interp = false; end
  if nargin < 5; CentreSliceOffset = [0 0 0]; end
  if nargin < 6; CopyGeomFromFName = []; end
  if nargin < 7; JustRotate = false; end
  
  % Check for multiple coils
%   if size(RawIms,5) > 1;
% 	  error('Not currently supporting multiple coil data...')
%   end

  
  % Interpolate if required
  if Interp == true
	  disp('Interpolating data...')
	  RawIms = InterpolateViaKSpace(RawIms,2);
	  Scales(1:2) = Scales(1:2)/2;
  end
  
  % Concatenate cycles in the third or fourth dimension
  disp('Concatenating cycles...')
  OutIm = [];
%   if length(size(RawIms)) == 4 % 2D data (RO,PE,time,cycle)
%     for cyc = 1:size(RawIms,4)
% 	  OutIm = cat(3,OutIm,RawIms(:,:,:,cyc));
%     end
% 
%     %  Rotate the data
%     disp('Rotating data...')
%     OutIm = RotateDynAngioData(OutIm,-1);
%     
%     % Swap the scales to account for this
%     tmp = Scales(1); Scales(1) = Scales(2); Scales(2) = tmp;
%   
%   else  % 3D data (RO,PE,Sl,time,cycle)
      
    for cyc = 1:size(RawIms,5)
	  OutIm = cat(4,OutIm,RawIms(:,:,:,:,cyc));
    end  
    
    if ~JustRotate
    isSAG = false;
    % Swap dimensions to convert from RO,PE,Slice -> x,y,z
    if ~isempty(regexp(OutFileName,'COR', 'once'))
        disp('Coronal view: reorienting...')
        % (RO,PE,Slice) = (z,x,y)
        PermOrder = [2 3 1 4 5];
        
    elseif ~isempty(regexp(OutFileName,'SAG', 'once'))
        disp('Sagittal view: reorienting...')
        % (RO,PE,Slice) = (z,y,x)
        PermOrder = [3 2 1 4 5];
        isSAG = true;
        
    else % Assume transverse
        disp('Transverse view: reorienting...')
        % (RO,PE,Slice) = (y,x,z)
        PermOrder = [2 1 3 4 5];
    end
    
    % Perform the permutation
    OutIm = permute(OutIm,PermOrder);
    Scales = Scales(PermOrder(1:4));
    
    disp(['Size of output image is now: ' ns(size(OutIm))])
    disp(['Scales are now: ' ns(Scales(:)')])
    
    % Flip dimensions to ensure consistent representation since readout is
    % S >> I in the z direction and we want increasing physical z with
    % voxel index in the third dimension.  Similarly, y is A >> P and we
    % want increasing physical y with voxel index in the second dimension.
    disp('Flipping y dimension...')
    OutIm = flipdim(OutIm,2);
    
    if ~isSAG  % Don't flip for SAG as it must be acquired I >> S
      disp('Flipping z dimension...')
      OutIm = flipdim(OutIm,3);
    end
    
    else % Just rotate the data
      disp('Rotating data...')
      OutIm = RotateDynAngioData(OutIm,-1);
    end
%   end
  


  if ~isreal(OutIm)
      
      % Save the image using Siemens phase convention
      disp('Saving magnitude and phase images...')
      
      % Determine the output file names:
      % If the output name is <Num>_description then insert mag and ph in the
      % right place
      OutName = regexprep( OutFileName, '.*/', '' );
      DirName = regexprep( OutFileName, OutName, '');
      
      if ~isempty( regexp( OutName, '^[0-9]*_' ) )
          OutMagFName = [DirName regexprep( OutName, '_', '_mag_', 'once' )];
          OutPhFName  = [DirName regexprep( OutName, '_', '_ph_' , 'once' )];
      else % Otherwise, put mag and ph at the end of the file name
          OutMagFName = [OutFileName '_mag'];
          OutPhFName = [OutFileName '_ph'];
      end
      
      disp(['Output file names are: ' OutMagFName ' and ' OutPhFName ]);
      
      Save_Mag_Ph(OutIm, OutMagFName, OutPhFName, Scales)
      
      % Apply the correct transformation matrices
      if isempty(CopyGeomFromFName)
        tosetniftiorientinfo(OutMagFName,Scales,size(OutIm),CentreSliceOffset);
        tosetniftiorientinfo(OutPhFName,Scales,size(OutIm),CentreSliceOffset);
      else
        cmd = ['fslcpgeom ' CopyGeomFromFName ' ' OutMagFName ' -d'];
        disp(cmd); system(cmd);
        cmd = ['fslcpgeom ' CopyGeomFromFName ' ' OutPhFName  ' -d'];
        disp(cmd); system(cmd);
      end
      
  else
      disp('Data not complex, saving real values...')
      save_avw( OutIm, OutFileName, 'f', Scales );
      
      % Apply the correct transformation matrices
      if isempty(CopyGeomFromFName)
        tosetniftiorientinfo(OutFileName,Scales,size(OutIm),CentreSliceOffset);
      else
        cmd = ['fslcpgeom ' CopyGeomFromFName ' ' OutFileName ' -d'];
        disp(cmd); system(cmd);
      end
  end
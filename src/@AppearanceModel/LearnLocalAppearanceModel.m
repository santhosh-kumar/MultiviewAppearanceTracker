%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function learns the local appearance model for different objects
%
%   Input -- 
%       @cameraNetwork  - Structure containing the camera networks.
%       @frameIndex     - frame index (number)
%   Output -- 
%       @cameraNetwork - Structure containing the camera networks.
%
%   Author  -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cameraNetwork = LearnLocalAppearanceModel( cameraNetwork,...
                                                    frameIndex )
   cameraNetwork.LearnLocalAppearance(frameIndex);
end
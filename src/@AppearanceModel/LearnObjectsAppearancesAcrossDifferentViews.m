%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function learns both local and global object appearance.
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
function cameraNetwork = LearnObjectsAppearancesAcrossDifferentViews( cameraNetwork,...
                                                                      frameIndex )
    % Learn local object appearance
    cameraNetwork = AppearanceModel.LearnLocalAppearanceModel( cameraNetwork,...
                                                               frameIndex );

    
    % Learn global appearance model
    cameraNetwork = AppearanceModel.LearnGlobalAppearanceModel( cameraNetwork,...
                                                                frameIndex );   
    
end
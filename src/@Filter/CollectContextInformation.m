%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function collects contextual information from the given camera
%   view
%
%   Input -- 
%       @cameraNetwork
%       @cameraIndex
%       @targetIndex
%
%   Output -- 
%       @zj  - current measurement on the ground plane
%
%   Author  -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ zj ] = CollectContextInformation( cameraNetwork,...
                                             cameraIndex,...
                                             targetIndex )
    zj =[];

    for targetId = 1 : cameraNetwork.GetCameraObject( cameraIndex ).GetNumberOfTargets()
        
        if  ( targetId ~= targetIndex && ...
                cameraNetwork.GetCameraObject( cameraIndex ).GetTarget(targetId).IsActive() )
            zj  = [ zj; cameraNetwork.GetCameraObject( cameraIndex ).GetTarget( targetId ).GetLocalMeasurement()];            
        end
    end
end
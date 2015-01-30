%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function learns both global object appearance.
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
function cameraNetwork = LearnGlobalAppearanceModel( cameraNetwork,...
                                                     frameIndex )

    for cameraIndex = 1 : cameraNetwork.GetNumberOfCameras( )
        % get the current frame image
        frameImage = cameraNetwork.GetCameraObject( cameraIndex ).GetFrame( frameIndex );
        
        % iterate every object and update the global appearance model
        for targetIndex =  1 : cameraNetwork.GetCameraObject( 1 ).GetNumberOfTargets( ) 

            % collect training examples per object in every camera from
            % every other views
            otherViewTrainingSamples = AppearanceModel.CollectTrainingSamples( cameraNetwork,...
                                                                             cameraIndex,...
                                                                             targetIndex );

           
            % update global appearance model            
            cameraNetwork.GetCameraObject( cameraIndex ).GetTarget( targetIndex ).UpdateGlobalAppearanceModel( frameImage,...
                                                                                                               otherViewTrainingSamples );
        end%targetIndex
    end%cameraIter                               
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function performs filtering.
%
%   Input -- 
%       @cameraNetwork          - Structure containing the camera networks
%
%   Output -- 
%       @cameraNetwork - Structure containing the camera networks
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cameraNetwork = PerformFiltering( cameraNetwork )

    assert( nargin == 1 );
    
    for cameraIndex = 1 : cameraNetwork.GetNumberOfCameras( )
        for targetIndex =  1 : cameraNetwork.GetCameraObject( 1 ).GetNumberOfTargets( ) 

            % Collect measurements from neighborhood cameras
            [ zi ] = Filter.CollectMeasurments(  cameraNetwork,...
                                                 cameraIndex,...
                                                 targetIndex );
                                             
            [ zj ] = Filter.CollectContextInformation(  cameraNetwork,...
                                                        cameraIndex,...
                                                        targetIndex );
                                             
            % Update filters
            cameraNetwork.GetCameraObject( cameraIndex ).GetTarget( targetIndex ).UpdateFilters( zi, zj );
            
        end%targetIndex
    end%cameraIter

end

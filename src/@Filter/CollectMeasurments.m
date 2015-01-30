%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function collects measurements from different cameras for the 
%   specified object.
%
%   Input -- 
%       @cameraNetwork  - Structure containing the camera networks.
%       @cameraIndex    - camera index
%       @targetIndex    - target index
%   Output -- 
%       @zi - measurement matrix
%
%   Author  -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zi = CollectMeasurments( cameraNetwork,...
                                  cameraIndex,...
                                  targetIndex )

    networkStructure = cameraNetwork.GetNetworkStructure( ); 
    assert( ~isempty( networkStructure ) );
    
    % initialize the output variable
    zi = [];    % measurment matrix

    measurementCount = 1;
    for otherCameraIndex = 1 : cameraNetwork.GetNumberOfCameras( )

        if networkStructure.adjacencyMatrix( cameraIndex, otherCameraIndex ) == 1 && otherCameraIndex ~= cameraIndex

            groundPlaneMeasurement = cameraNetwork.GetCameraObject( otherCameraIndex ).GetTarget( targetIndex ).GetGroundPlaneMeasurement( );
            if isempty( groundPlaneMeasurement ) 
                continue;
            end

            zi( measurementCount, : ) = groundPlaneMeasurement;

            measurementCount = measurementCount + 1;

        end

    end   
end% function
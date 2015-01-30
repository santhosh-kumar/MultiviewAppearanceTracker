%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function learns both local and global object appearance.
%
%   Input -- 
%       @cameraNetwork  - Structure containing the camera networks.
%       @cameraIndex    - camera index
%       @targetIndex    - target index
%   Output -- 
%       @otherViewTrainingSampleList - cell of training samples from other
%       views
%   Author  -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function otherViewTrainingSampleList = CollectTrainingSamples( cameraNetwork,...
                                                               cameraIndex,...
                                                               targetIndex )
                                                           
     networkStructure = cameraNetwork.GetNetworkStructure( ); 
     assert( ~isempty( networkStructure ) );
                                                        
     otherViewTrainingSampleList = {};
     count = 1;
     for otherCameraIndex = 1 : cameraNetwork.GetNumberOfCameras( )
         
        % if an adjacent camera is available
        if networkStructure.adjacencyMatrix( cameraIndex, otherCameraIndex ) == 1 && otherCameraIndex ~= cameraIndex
                        
            % get the training samples
            trainingSamples = cameraNetwork.GetCameraObject( otherCameraIndex ).GetTarget( targetIndex ).GetGlobalTrainingSamples( );
            
            % add to list if it is not empty
            if ~isempty( trainingSamples ) 
                otherViewTrainingSampleList{count} = trainingSamples;
                count = count + 1;
            end
        end
     end                                              
end
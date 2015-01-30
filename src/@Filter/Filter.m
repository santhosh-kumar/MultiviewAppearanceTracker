%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Filter takes care of updating local and global filters

%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Filter < handle

    methods(Static)
        
        % Performs consensus based on the options specified
        cameraNetwork = PerformFiltering(  cameraNetwork );
                                       
    end%static methods
    
    methods( Static, Access = private )
        
       % Collect Measurements from other cameras for the corresponding target                   
       [ zi ] = CollectMeasurments( cameraNetwork,...
                                    cameraIndex,...
                                    targetIndex );

       % Collects spatial context information for contextual fusion
       [ zj ] = CollectContextInformation( cameraNetwork,...
                                           cameraIndex,...
                                           targetIndex );
    end
   
end%classdef
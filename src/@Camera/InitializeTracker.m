%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function initializes target manually.
%
%   Input -- 
%       @obj - camera object.
%       @localFeatureType - Feature Type for appearance modeling
%       @globalFeatureType - Feature Type for global appearance modeling
%   Output -- 
%       @obj - camera object
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = InitializeTracker(   obj,...
                                    frameNumber,...
                                    localFeatureType,...
                                    globalFeatureType )  
                                
                                
    assert( nargin >= 2 );
    if nargin < 4
        globalFeatureType = 0;
        if nargin < 3
            localFeatureType = 'RAW_COLOR';
            if nargin < 2
                frameNumber = 1;
            end
        end
    end
    
    initializationImageFrame        = obj.GetFrame( frameNumber );

    if obj.m_useInitMat
        initRect = [];
        load( fullfile(obj.m_videoPath, 'initRect.mat') );
        initMat = initRect{obj.m_cameraID};
        for i = 1 : obj.m_numberOfObjects
           targetRect = initMat( i, : );

           % if valid object rectangle available
           if sum(targetRect) ~= 0
               obj.m_targetList{i} = Target( obj.m_cameraID,...
                                              i,...
                                              obj.GetHomography(),...
                                              obj.GetCameraModel(),...
                                              initializationImageFrame,...
                                              targetRect,...
                                              1,...
                                              localFeatureType,...
                                              globalFeatureType,...
                                              obj.s_trajectoryDatabase );
           else
               obj.m_targetList{i} = Target( obj.m_cameraID,...
                                           i,...
                                           obj.GetHomography( ),...
                                           obj.GetCameraModel( ) );
           end
        end
    end    
end  %function
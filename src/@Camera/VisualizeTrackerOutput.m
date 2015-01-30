%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Visualizes the tracker output
%
%   Input -- 
%       @obj           - Camera object
%       @networkStruct - Information about the network structure
%
%   Output -- 
%       void
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function VisualizeTrackerOutput( obj, networkStructure )

    %display the current frame
    frameNumber = networkStructure.clock;
    frame = figure( obj.m_cameraID * 100 );
    imshow( obj.GetFrame( frameNumber ) );

    hold on;
    for targetIndex = 1 : obj.m_numberOfObjects
        %is target active
        if obj.IsTargetActive( targetIndex )
            %draw the object rectangle
            obj.DrawRectangle( obj.m_targetList{targetIndex}.GetTargetRectangle(),...
                               [0 1 0], 2 );
        end
    end
    hold off;
    
    % Add to output stream
    obj.AddFrameToOutputStream( getframe(frame) );
end%function

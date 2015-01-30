%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function is for preparing foreground and background masks that are
%   are used in training.
%
%   Input -- 
%       @obj                - object of type EnsembleClassifier
%       @frameImage         - image of the current frame
%       @objectRectangle    - rectangle of the target on image
%       @phase              - 'TRAIN' or 'TEST'
%
%   Output -- 
%       @obj                - object of type Target
%       @objectRectangle    - adjusted object rectangle
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ obj, objectRectangle ] = PrepareForegroundAndBackgroundMasks(    obj,...
                                                                            frameImage,...
                                                                            objectRectangle,...
                                                                            phase )
    
    warning('off');
    
    assert( nargin >= 3 );
    assert( ~isempty( frameImage ) );
    
    if nargin < 4
        phase = 'TRAIN';
    end
    
    [ numberOfRows, numberOfColumns, ~ ] = size( frameImage );
    
    % initialize the mask image to zeros.
    innerRectangleMask = zeros( numberOfRows, numberOfColumns );
    outerRectangleMask = zeros( numberOfRows, numberOfColumns );

    %making odd width and height
    objectRectangle(3) = objectRectangle(3) + ( 1-mod(objectRectangle(3), 2) );
    objectRectangle(4) = objectRectangle(4) + ( 1-mod(objectRectangle(4), 2) );

    h = objectRectangle(4); 
    w = objectRectangle(3); 

    % Another .5 is for splitting it on both sides of window
    if ( strcmp( phase, 'TRAIN') || strcmp( phase, 'TEST') )
        rect_width = ceil( .5 .* .5 .* ( sqrt( ( h + w )^2 + ( 4 * h * w ) ) - ( h + w ) ) );
        rect_width = rect_width + ( 1-mod(rect_width, 2) );
    else
        rect_width = max( h, w ) /2;
    end
    outerRectangleWidth = rect_width + 0;

    if ( objectRectangle(3) > ( numberOfColumns - 2*rect_width ) )
        objectRectangle(3) = numberOfColumns - 2*rect_width; 
    end

    if ( objectRectangle(4) > ( numberOfRows - 2 * rect_width ) )
        objectRectangle(4) = numberOfRows - 2*rect_width; 
    end

    % Pick Out Foreground Pixels
    if ( objectRectangle(1) < rect_width+1 )
       objectRectangle(1) = rect_width+1;   
    end

    if ( objectRectangle(2) < rect_width+1 )
       objectRectangle(2) = rect_width+1;   
    end

    if ( objectRectangle(1) > numberOfColumns - objectRectangle(3) - rect_width )
       objectRectangle(1) =  numberOfColumns - objectRectangle(3) - rect_width + 1; 
    end

    if ( objectRectangle(2) > numberOfRows - objectRectangle(4) - rect_width )
       objectRectangle(2) =  numberOfRows - objectRectangle(4) - rect_width + 1; 
    end
    
    inner_rect = [objectRectangle(2) objectRectangle(2)+objectRectangle(4)-1 objectRectangle(1) objectRectangle(1)+objectRectangle(3)-1];
    innerRectangleMask(inner_rect(1):inner_rect(2), inner_rect(3):inner_rect(4)) = 1; 


    if ( strcmp( phase, 'TRAIN') )
        % Pick out background Pixels  
        outer_rect = [inner_rect(1)-rect_width, inner_rect(2)+rect_width, inner_rect(3)-rect_width, inner_rect(4)+rect_width];
    else
        outer_rect = [inner_rect(1)-outerRectangleWidth, inner_rect(2)+outerRectangleWidth, inner_rect(3)-outerRectangleWidth, inner_rect(4)+outerRectangleWidth];
        %outer_rect = [ 1 size(frameImage,1) 1 size(frameImage,2)];
    end
    
    outerRectangleMask(outer_rect(1):outer_rect(2), outer_rect(3):outer_rect(4)) = 1;

    outerRectangleMask = outerRectangleMask - innerRectangleMask;

    % set the foreground and background mask regions
    obj.m_foregroundRegionMask = find( innerRectangleMask );
    obj.m_backgroundRegionMask = find( outerRectangleMask );

    [~, sortIdx] = sort([obj.m_backgroundRegionMask; obj.m_foregroundRegionMask]);

    obj.m_foregroundBackgroundShuffleIndices    = sortIdx;
    obj.m_numberOfRowsForBoosting               = outer_rect(2) - outer_rect(1) + 1;
    obj.m_numberOfColumnsForBoosting            = outer_rect(4) - outer_rect(3) + 1;
    
    warning('on');
end
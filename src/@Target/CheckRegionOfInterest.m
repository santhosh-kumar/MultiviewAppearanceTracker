%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function checks region of interest for the given frameNumber.
%   Give in an image with 2 rectangles in the image, get out all pixels.
%   This is done for getting the inner and outer masks used in the
%   subsequent training process.
%
%   Input -- 
%       @obj        - Target object
%       @frameImage - image of the current frame
%   Output -- 
%        @obj       - target object
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = CheckRegionOfInterest( obj, frameImage )
    
    try
        assert( nargin == 2 );
        assert( ~isempty( frameImage ) );
        
        [ obj.m_ensembleClassifier, obj.m_rectangle ] = ...
            obj.m_ensembleClassifier.PrepareForegroundAndBackgroundMasks(   frameImage,...
                                                                            ceil(obj.m_rectangle) );
    catch ex
        throwAsCaller( ex );
    end
    
end
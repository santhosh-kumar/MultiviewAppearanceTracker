%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Initialize particle filter
%
%   Input -- 
%       @obj - object of type ParticleFilter
%       @centerX -  x center of the object
%       @centerY -  y center of the object
%       @scaleX  -  x scale
%       @scaleY  -  y scale
%       @maxScaleChangeInOneInterval - max scale change between frames
%       @maxScaleChange - maximum allowed scale change
%       @minScaleChange - minimum scale allowed
%      
%   Output -- 
%       @obj - object of type ParticleFilter
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = Initialize( obj,...
                           centerX,...
                           centerY,...
                           scaleX,...
                           scaleY,...
                           maxScaleChangeInOneInterval,...
                           maxScaleChange,...
                           minScaleChange )
    try
       assert( nargin >= 5 );

       %set the default values
       if nargin < 8
            obj.m_minScaleChange = 0.1;
            if nargin < 7
                obj.m_maxScaleChange = 1.5;
                if nargin < 6
                    obj.m_maxScaleChangeInOneInterval = maxScaleChangeInOneInterval;
                end
            end
       end

       obj.m_maxScaleChange = maxScaleChange;
       obj.m_minScaleChange = minScaleChange;
       obj.m_maxScaleChangeInOneInterval = maxScaleChangeInOneInterval;

       %initialize the state matrix
       obj.m_stateMatrix = repmat( [ centerX, centerY, scaleX, scaleY, 1],...
                                    obj.m_numberOfParticles, 1 );
                                
                                
       % set the original state matrix
       obj.m_originalStateMatrix = obj.m_stateMatrix;

    catch ex
       error( [ 'Failed to initialize particle filter:', ex] );
    end

end%function
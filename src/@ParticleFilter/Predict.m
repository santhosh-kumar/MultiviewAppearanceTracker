%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Predict the particle state with brownian motion
%
%   Input -- 
%       @obj - object of type ParticleFilter
%       @varianceX          -  x position variance
%       @varianceY          -  y position variance
%       @varianceScaleX     -  x scale variance
%       @varianceScaleY     -  y scale variance
%      
%   Output -- 
%       @obj - object of type ParticleFilter
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = Predict( obj,...
                        varianceX,...
                        varianceY,...
                        varianceScaleX,...
                        varianceScaleY )
    try
        assert( nargin == 5 );

        varianceX        = max( 1e-10, varianceX );
        varianceY        = max( 1e-10, varianceY );
        varianceScaleX   = max( 1e-10, varianceScaleX );
        varianceScaleY   = max( 1e-10, varianceScaleY );

        mu    = [ 0 0 0 0];
        sigma = [   varianceX 0 0 0;
                    0 varianceY 0 0;
                    0 0 varianceScaleX 0;
                    0 0 0 varianceScaleY ];
                
        %cholesky factorization for getting a proper covariance matrix
        R = chol(sigma);

        z = repmat(mu,obj.m_numberOfParticles,1) + randn( obj.m_numberOfParticles, 4 ) * R;
        
        obj.m_predictedStateMatrix( :, 1:obj.m_stateDimension ) = obj.m_stateMatrix(:, 1:4)  + z;

        % correct the maximum and minimum scales
        obj.m_predictedStateMatrix( :, 3 ) = max(min( obj.m_predictedStateMatrix( :, 3 ),...
                                   obj.m_maxScaleChange .* ones( obj.m_numberOfParticles, 1 ) ), obj.m_minScaleChange .* ones( obj.m_numberOfParticles, 1 ));

        obj.m_predictedStateMatrix( :, 4 ) = max(min( obj.m_predictedStateMatrix( :, 4 ),...
                                   obj.m_maxScaleChange .* ones( obj.m_numberOfParticles, 1 ) ), obj.m_minScaleChange .* ones( obj.m_numberOfParticles, 1 ));
        
        %increment the time index
        obj.m_timeIndex  = obj.m_timeIndex  + 1;

    catch ex
        error( [ 'Failed to predict particle filter:', ex] );
    end
    
end%function

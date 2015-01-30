%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Update the particle weights
%
%   Input -- 
%       @obj                    - object of type ParticleFilter
%       @posteriorStateMatrix   - posterior state matrix
%      
%   Output -- 
%       @obj - object of type ParticleFilter
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = Update( obj,...
                       posteriorStateMatrix )
   % update the state matrix
   obj.m_stateMatrix( :, 1 : obj.m_stateDimension ) = posteriorStateMatrix;
end
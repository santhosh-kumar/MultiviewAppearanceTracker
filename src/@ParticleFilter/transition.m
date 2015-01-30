%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Transition the statematrix according to constant velocity mdoel.
%
%   Input -- 
%       @obj - object of type ParticleFilter
%      
%   Output -- 
%       @transitionStateMatrix - transitioned state matrix
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function transitionStateMatrix = transition( obj )
    stateMatrix         = obj.m_stateMatrix;
    originalStateMatrix = obj.m_originalStateMatrix;
    predictedMatrix     = obj.m_predictedStateMatrix;
    
    Np = obj.m_numberOfParticles;
    
    x  = ParticleFilter.A1 * ( stateMatrix(:,1) - originalStateMatrix(:,1) ) + ParticleFilter.A2 * ( predictedMatrix(:,1) - originalStateMatrix(:,1) ) + ParticleFilter.B0 * 12 * ParticleFilter.TRANS_X_STD * randn(Np, 1) + originalStateMatrix(:,1);
    y  = ParticleFilter.A1 * ( stateMatrix(:,2) - originalStateMatrix(:,2) ) + ParticleFilter.A2 * ( predictedMatrix(:,2) - originalStateMatrix(:,2) ) + ParticleFilter.B0 * 1 * ParticleFilter.TRANS_Y_STD * randn(Np, 1) + originalStateMatrix(:,2);
    sx = ParticleFilter.A1 * ( stateMatrix(:,3) - originalStateMatrix(:,3) ) + ParticleFilter.A2 * ( predictedMatrix(:,3) - originalStateMatrix(:,3) ) + ParticleFilter.B0 * 1 * ParticleFilter.TRANS_SX_STD * randn(Np, 1) + originalStateMatrix(:,3);
    sy = ParticleFilter.A1 * ( stateMatrix(:,4) - originalStateMatrix(:,4) ) + ParticleFilter.A2 * ( predictedMatrix(:,4) - originalStateMatrix(:,4) ) + ParticleFilter.B0 * 1 * ParticleFilter.TRANS_SY_STD * randn(Np, 1) + originalStateMatrix(:,4);
    
    transitionStateMatrix = [x y sx sy];
 
end
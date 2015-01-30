%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This file sets the global constants.
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Enable Logging
global ENABLE_LOGGING
ENABLE_LOGGING                          = 1;

%% RESET_INTERVAL
global RESET_INTERVAL
RESET_INTERVAL                          = inf; 

%% Should Use Particle Filtering
global USE_PARTICLE_FILTERING
USE_PARTICLE_FILTERING                  = 1;

%% Type of features used for analysis
global LOCAL_FEATURE_TYPE
LOCAL_FEATURE_TYPE  = 'HOG_AND_COLOR';     % 'RAW_COLOR' or 'HOG' or 'HOG_AND_COLOR'

global GLOBAL_FEATURE_TYPE
GLOBAL_FEATURE_TYPE = 'HOG_AND_COLOR';     % 'RAW_COLOR' or 'HOG' or 'HOG_AND_COLOR'

%% Should visualize particles from particle filter or not
global SHOULD_VISUALIZE_PARTICLES
SHOULD_VISUALIZE_PARTICLES              = 0;     % 0 or 1

%% Should visualize marginals
global SHOULD_VISUALIZE_MARGINALS
SHOULD_VISUALIZE_MARGINALS              = 1;     % 0 or 1

%% Initialization Frame Number
global INITIALIZATION_FRAME_NUMBER
INITIALIZATION_FRAME_NUMBER             = 1;

%% Should use init mat or not
global SHOULD_USE_INIT_MAT
SHOULD_USE_INIT_MAT = 1;

%% MATLAB pool
global MATLAB_POOL_ENABLED
MATLAB_POOL_ENABLED = 0;
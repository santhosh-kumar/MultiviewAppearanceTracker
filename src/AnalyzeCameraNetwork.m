%% Clean up
clear all; 
close all; 
clc;

%% Load Constants
Constants();

%% Logging
if ( ENABLE_LOGGING )
    global FID %#ok<TLEV>
    FID = fopen(fullfile('logs','DistributedTrackLog.log'),'w+');
    assert( FID ~= -1 );
    TRACE_LOG('===============================Start===================================');
end


%% open the matlab pool
if MATLAB_POOL_ENABLED
    try
        matlabpool;
    catch ex
        fprintf( 'Pool is already running \n' );
    end
end

%% Run Detectors on the Frames to estimate Camera States
try
    % Set up the camera network
    [ cameraNetwork, frameRangeForAnalysis ] = SetupCameraNetwork( );
    
    % Initialize Tracker Across Different Views
    cameraNetwork.InitializeTrackerAcrossDifferentViews( INITIALIZATION_FRAME_NUMBER,...          % initializationFrameNumber
                                                         LOCAL_FEATURE_TYPE,...                   % localFeatureType
                                                         GLOBAL_FEATURE_TYPE...                   % globalFeatureType
                                                       );               
                                                   
    % Iterate Over time to estimate States using Prior Information
    for frameIndex = INITIALIZATION_FRAME_NUMBER + 1 : numel( frameRangeForAnalysis(1): frameRangeForAnalysis(2) )

        TRACE_LOG(  [ '=============================== Clock Tick: ' num2str(frameIndex) '===============================' ] );
        
        % test on the given frame
        cameraNetwork = cameraNetwork.TrackObjectsAcrossDifferentViews( frameIndex );
        
        % perform filtering
        cameraNetwork = Filter.PerformFiltering(  cameraNetwork );

        % update the appearance model
        cameraNetwork = AppearanceModel.LearnObjectsAppearancesAcrossDifferentViews( cameraNetwork, frameIndex );
        
        % visualize the output
        cameraNetwork.VisualizeNetworkAnalysisOutput( );
        
    end%for frameIndex
    
    if ( ENABLE_LOGGING )
        TRACE_LOG( '===============================End===================================' );
        fclose(FID);
    end %if ENABLE_LOGGING
    
    % close the output stream
    cameraNetwork.CloseOutputStream( );
    
    %save the results
    cameraNetwork.SaveResults();
    
catch ex
    if ( ENABLE_LOGGING )
        TRACE_LOG( ex.message );
        TRACE_LOG( '===============================Exception Stack========================' );
        TRACE_LOG( [ex.stack.file] );
        TRACE_LOG( [ex.stack.line] );
        TRACE_LOG( [ex.stack.name] );
        TRACE_LOG( '===============================End===================================' );
        fclose(FID);
    end
end

%% close the matlab pool
if MATLAB_POOL_ENABLED
    try
        matlabpool close;
    catch ex
        fprintf( 'Pool is already Closed \n' );
    end
end
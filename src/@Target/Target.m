%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This class encapsulates all the target related features.
%   Target class holds the state space related information.
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Target < handle
    
   properties(  GetAccess = 'public',...
                SetAccess = 'private' )
        
        m_cameraId;                    % camera Id of the target
        m_homographyMatrix;            % camera homography passed from the camera
        m_cameraModel;                 % camera calibration model
        m_targetId;                    % target ID
        m_isActive;                    % active or not
        
        m_width;                       % initial width
        m_height;                      % initial height
        m_objRectangle;                % stores the current state of the object rectangle
        m_occlusionCount;              % counts the number of frames the object is occluded 
        m_appearanceTrainingRectangle; % object recatangle for appearance training
        m_aspectRatio;                 % aspect ratio of the object
        m_imageResolution;             % number of rows x number of columns
        
        m_localFeatureType;            % feature type for the local classifier
        m_localClassifier;             % local ensemble classifier
        
        m_globalFeatureType;           % feature type for the global classifier
        m_globalClassifier;            % global ensemble classifier
        
        m_isParticleFilterEnabled;     % is particle filter enabled
        m_localParticleFilter;         % model the local information
        m_globalParticleFilter;        % models the global information
 
        m_trajectoryDatabase;          % scene related information
        m_trackingResults;             % to store the results
        
        m_groundPlaneTrajectoryHistory;% ground plane trajectory history
        m_imagePlaneTrajectoryHistory; % Trajectory history on the image plane
        
        m_localConfidenceMap;          % local confidence map
        m_globalConfidenceMap;         % global confidence map
        m_localObjRectangle;           % local object rectangle
        m_globalObjRectangle;          % global object rectangle
          
   end%properties
   
   properties(Constant)
       s_numberOfParticles              = 500; % number of particles
       s_numberOfBurninIteration        = 0;
       s_particleFilterStateDimension   = 4;   % dimension of the state variable X
       
       % local particle filter's motion parameters
       s_varianceX                      = 441;
       s_varianceY                      = 6;
       s_scaleVarianceX                 = 0.001;
       s_scaleVarianceY                 = 0.001;
       
       % global particle filter's motion parameters
       s_varianceXg                     = 441;
       s_varianceYg                     = 6;
       s_scaleVarianceXg                = 0.001;
       s_scaleVarianceYg                = 0.001;
       
       % object scale related parameters
       s_maxScaleChangeInOneInterval    = 0.05;
       s_maxScaleChange                 = 1.05;
       s_minScaleChange                 = 0.95;
     
       
       TARGET_ACTIVE_THRESHOLD          = 20;
       GAMMA                            = 0.1; % threshold for interaction in MCMC sampling
       INTERACTIVE_NORMALIZATION_SIGMA  = 10 * 10;
       INTERACTIVE_NORMALIZATION_BETA   = 1;
       MC_NORMALIZATION_SIGMA           = 1000;
       MC_NORMALIZATION_RHO             = 1;
       
       USE_MAXIMUM_LIKELIHOOD_FOR_WEIGHTING     = 0;
       MIN_PARTICLE_GP_POSTERIOR_NORM_THRESHOLD = 10;%10 pixels
       
       DIMENSION_GLOBAL_FEATURE         = 17;
       CONFIDENCE_THRESHOLD             = 0.1;
   end%constant properties
   
    methods( Access = public )
       
        % Constructor
        function obj = Target( cameraId,...
                               targetId,...
                               homographyMatrix,...
                               cameraModel,...
                               initializationImageFrame,...
                               objectRectangle,...
                               isTargetActive,...
                               localFeatureType,...
                               globalFeatureType,...
                               trajectoryDatabase )
                          
            try
                assert( nargin >= 4 );
                assert( targetId ~= 0 );
                assert( cameraId ~= 0 );
                
                obj.m_cameraId                  = cameraId;
                obj.m_targetId                  = targetId;
                obj.m_homographyMatrix          = homographyMatrix;
                obj.m_cameraModel               = cameraModel;
                
                % set the default values
                if nargin < 10
                    trajectoryDatabase = [];
                    if nargin < 11
                        globalFeatureType = 'RAW_COLOR';
                        if nargin < 10
                            globalFeatureType = 'RAW_COLOR';
                            if nargin == 4
                                objectRectangle                   = [];
                                isTargetActive                    = false;
                                initializationImageFrame          = [];
                            end
                        end
                    end
                end
                
                obj.m_isActive                  = isTargetActive;
                obj.m_occlusionCount            = 0;
                
                obj.m_imageResolution           = [size(initializationImageFrame,1) size(initializationImageFrame,2)];
                obj.m_trajectoryDatabase        = trajectoryDatabase;
                
                % if the target is active
                if isTargetActive
                    assert( nargin >= 3 );
      
                    obj.m_objRectangle          = objectRectangle;
                    obj.m_width                 = objectRectangle(3);
                    obj.m_height                = objectRectangle(4);
                    obj.m_trackingResults       = objectRectangle;
                    
                    if ~isempty( objectRectangle )
                        assert( length(objectRectangle) == 4 );
                        obj.m_aspectRatio = objectRectangle(3) / objectRectangle(4);
                    end
                    
                    % initialize local and global particle filters
                    obj.InitializeParticleFilter( objectRectangle,...
                                                  obj.m_imageResolution(1),...
                                                  obj.m_imageResolution(2) );

                    obj.m_localFeatureType      = localFeatureType;
                    obj.m_globalFeatureType     = globalFeatureType;
                    
                    obj.m_localConfidenceMap    = [];                   % local confidence map
                    obj.m_globalConfidenceMap   = [];                   % global confidence map
                    obj.m_localObjRectangle     = objectRectangle;      % local object rectangle
                    obj.m_globalObjRectangle    = objectRectangle;      % global object rectangle
                    
                    obj.m_groundPlaneTrajectoryHistory  = Camera.ProjectToGroundPlane( obj.m_objRectangle, obj.m_homographyMatrix, obj.m_cameraModel );
                    obj.m_imagePlaneTrajectoryHistory   = objectRectangle; % Trajectory history on the image plane
       
                    
                    % initialize the local and global appearance models
                    obj.InitializeEnsembleClassifier( initializationImageFrame );
                end
              
            catch ex
                throwAsCaller( ex );
            end
        end
        
        % Getter for is target active or not
        function isActive = IsActive( obj )
            isActive = obj.m_isActive;
        end
        
        % Getter for the target id
        function targetId = GetTargetId( obj )
            targetId = obj.m_targetId;
        end
        
        % Get object rectangle
        function rectangle = GetTargetRectangle(obj)
            rectangle = obj.m_objRectangle;
        end
        
        % Append and update object rectangle
        function obj = AppendToTrackingResults( obj,...
                                                isAssigned,...
                                                objRect )
            if isAssigned
                obj.m_trackingResults  = [ obj.m_trackingResults; objRect ];
                obj.m_objRectangle     = objRect;
            else
                obj.m_trackingResults  = [ obj.m_trackingResults; obj.m_objRectangle ];
            end
        end
        
        % Get ground plane measurement
        function measurement = GetGroundPlaneMeasurement( obj )
            measurement = [];
            if ( obj.IsActive( ) )
                measurement = Camera.ProjectToGroundPlane( obj.m_globalObjRectangle, obj.m_homographyMatrix, obj.m_cameraModel );
            end
        end
        
        % Get local measurment
        function measurement = GetLocalMeasurement( obj )
            measurement = obj.m_localObjRectangle;
        end
        
        % Get ground plane trajectory history
        function groundPlaneTrajectoryHistory = GetGroundPlaneTrajectoryHistory( obj )
            groundPlaneTrajectoryHistory = obj.m_groundPlaneTrajectoryHistory;
        end
        
        % Get ground plane trajectory history
        function imagePlaneTrajectoryHistory = GetImagePlaneTrajectoryHistory( obj )
            imagePlaneTrajectoryHistory = obj.m_imagePlaneTrajectoryHistory;
        end
        
        % Initialize Particle Filters
        function obj = InitializeParticleFilter( obj,...
                                                objRectangle,...
                                                imageWidth,...
                                                imageHeight )
           % initialize local particle filter                       
           obj.m_localParticleFilter  = ParticleFilter( obj.s_numberOfParticles,...
                                                        objRectangle,...
                                                        imageHeight,...
                                                        imageWidth,...
                                                        obj.s_particleFilterStateDimension ); 
            
           % initialize global particle filter
           obj.m_globalParticleFilter = ParticleFilter( obj.s_numberOfParticles,...
                                                        objRectangle,...
                                                        imageHeight,...
                                                        imageWidth,...
                                                        obj.s_particleFilterStateDimension );
 
           % initialize the particle filter
           centerX                      = objRectangle(1) + objRectangle(3)/2;
           centerY                      = objRectangle(2) + objRectangle(4)/2;
           scaleX                       = 1;
           scaleY                       = 1;
 
                                         
           % initialize the local particle filter
           obj.m_localParticleFilter.Initialize( centerX,...
                                                 centerY,...
                                                 scaleX,...
                                                 scaleY,...
                                                 obj.s_maxScaleChangeInOneInterval,...
                                                 obj.s_maxScaleChange,...
                                                 obj.s_minScaleChange );
                                           
           % initialize the global particle filter
           obj.m_globalParticleFilter.Initialize( centerX,...
                                                  centerY,...
                                                  scaleX,...
                                                  scaleY,...
                                                  obj.s_maxScaleChangeInOneInterval,...
                                                  obj.s_maxScaleChange,...
                                                  obj.s_minScaleChange );
        end
        
        % Initialize ensemble classifier - both local and global
        function obj = InitializeEnsembleClassifier( obj,...
                                                     initializationImageFrame,...
                                                     numberOfLocalWeakClassifiers,...
                                                     numberOfLocalWeakClassifiersChanged,...
                                                     numberOfGlobalWeakClassifiers,...
                                                     numberOfGlobalWeakClassifiersChanged )
            assert( nargin >= 2 );
            
            if nargin < 6
                numberOfGlobalWeakClassifiersChanged = 1;
                if nargin < 5
                    numberOfGlobalWeakClassifiers = 12;
                    if nargin < 4
                        numberOfLocalWeakClassifiersChanged = 3;
                        if nargin < 3
                            numberOfLocalWeakClassifiers = 12;
                        end
                    end
                end
            end
            
            
            try
                % feature options
                localFeatureOptions.spatialBinSize = 9;
                localFeatureOptions.orientations   = 12;
                
                % dimensionality reduction options
                localDROptions.enabled = false;
                
                % initialize local classifier
                obj.m_localClassifier = EnsembleClassifier( initializationImageFrame,...
                                                            obj.m_objRectangle,...
                                                            numberOfLocalWeakClassifiers,...
                                                            numberOfLocalWeakClassifiersChanged,...
                                                            obj.m_localFeatureType,...
                                                            localFeatureOptions,...
                                                            localDROptions );
                                                        
                % enable dimensionality reduction for global features                                        
                globalDROptions.enabled = true;
                globalDROptions.d       = Target.DIMENSION_GLOBAL_FEATURE;
                
                % feature options
                globalFeatureOptions.spatialBinSize = 3;
                globalFeatureOptions.orientations   = 36;
                                                        
                % initialize global classifier                                   
                obj.m_globalClassifier = EnsembleClassifier( initializationImageFrame,...
                                                            obj.m_objRectangle,...
                                                            numberOfGlobalWeakClassifiers,...
                                                            numberOfGlobalWeakClassifiersChanged,...
                                                            obj.m_globalFeatureType,...
                                                            globalFeatureOptions,...
                                                            globalDROptions );
            catch ex
                throwAsCaller(ex);
            end
        end
        
        % Track object on the given frame
        function obj = TrackObjectOnTheGivenFrame( obj, frameImage )
            assert( nargin == 2 );
            
            if obj.IsActive( )
                assert( ~isempty(frameImage) );

                % get local model measurement
                [ obj.m_localClassifier, obj.m_localObjRectangle, obj.m_localConfidenceMap ]...
                        = obj.m_localClassifier.Test( frameImage,...
                                                      obj.m_objRectangle,...
                                                      true );
   
                obj.m_localObjRectangle =  Target.GetValidBoundingBox( obj.m_localObjRectangle, obj.m_imageResolution(2), obj.m_imageResolution(1) );
                
                % get global model measurement
                [ obj.m_globalClassifier, obj.m_globalObjRectangle, obj.m_globalConfidenceMap ]...
                        = obj.m_globalClassifier.Test( frameImage,...
                                                       obj.m_objRectangle,...
                                                       true );
                                                   
                obj.m_globalObjRectangle =  Target.GetValidBoundingBox( obj.m_globalObjRectangle, obj.m_imageResolution(2), obj.m_imageResolution(1) );
            end
        end
        
        % Update Filters
        function obj = UpdateFilters( obj,...
                                      otherCameraGroundMeasurements,...
                                      otherObjectMeasurements )

            if ~obj.IsActive( )
                return;
            end

            localRect = int64( obj.m_localObjRectangle );
            % Check the confidence score for local tracker and if it's below a threshold, set occlussion flag.
            confidenceLkhd = sum( sum( obj.m_localConfidenceMap( localRect(2) : localRect(2) + localRect(4),...
                                                                            localRect(1) : localRect(1) + localRect(3) ) ) )...
                                                    ./ double( localRect(3) * localRect(4) );
                                                
            % occlussion occurred        
            if ( confidenceLkhd < Target.CONFIDENCE_THRESHOLD )
                % reset the occlusion count
                obj.m_occlusionCount = obj.m_occlusionCount + 1;
            else
                obj.m_occlusionCount = 0;
            end
            
            % perform IMCMC based particle filtering
            obj.PerformIMCMC( otherCameraGroundMeasurements,...
                              otherObjectMeasurements );
                          
            % make the target inactive if its occluded for a while
            if obj.m_occlusionCount > obj.TARGET_ACTIVE_THRESHOLD
                obj.m_isActive = 0;
            end  
        end
        
        % Perform IMCMC based Tracking
        function obj = PerformIMCMC( obj,...
                                     otherCameraGroundMeasurements,...
                                     otherObjectMeasurements )
            
            % update global particle filter
            obj.UpdateGlobalParticleFilter( otherCameraGroundMeasurements );
            
 
            % update the local particle filter
            obj.UpdateLocalParticleFilter( otherObjectMeasurements, otherCameraGroundMeasurements);
                                       
                        
            % update the object state with the posterior
            obj.UpdateObjectRectangleWithPosterior( );
        end
        
        % Update the global particle filter
        function obj = UpdateGlobalParticleFilter( obj,...
                                                   otherCameraGroundMeasurements )
                                               
            
            % predict local particle filter
            obj.m_globalParticleFilter.Predict( obj.s_varianceXg,...
                                                obj.s_varianceYg,...
                                                obj.s_scaleVarianceXg,...
                                                obj.s_scaleVarianceYg );
                                            
            % transition the state according to the global transition model
            transitionState     = obj.m_globalParticleFilter.transition( );
            
            % get the predicted state                                 
            gPredictedState     = obj.m_globalParticleFilter.GetPredictedState( ); 
            
            assert( length( transitionState ) == length( gPredictedState )  );
            
            gPosteriorState     = zeros( length( transitionState ), obj.s_particleFilterStateDimension );
            
            % initialize weights
            weightList          = zeros( 1, length( gPosteriorState ) );
                       
            % Define the sigma for the proposal density with the motion model
            gSigma              = eye( obj.s_particleFilterStateDimension );
            gSigma(1,1)         = obj.s_varianceXg;
            gSigma(2,2)         = obj.s_varianceYg;
            gSigma(3,3)         = obj.s_scaleVarianceXg;
            gSigma(4,4)         = obj.s_scaleVarianceYg ;
            R = chol(gSigma);
            
            % perform burn-in iterations
            for i = 1 : Target.s_numberOfBurninIteration
                % randomly select a particle
                selectSample = randi( length( gPredictedState ) );

                % predict using the conditional motion model
                predictedSample = ParticleFilter.PredictParticle( obj.s_varianceX,...
                                                                obj.s_varianceY,...
                                                                obj.s_scaleVarianceX,...
                                                                obj.s_scaleVarianceY,... 
                                                                gPredictedState(selectSample, 1:4) );

                prevLikelihood =  obj.evaluateGlobalFilterLikelihood( otherCameraGroundMeasurements, gPredictedState(selectSample, 1:4));
                predLikelihood =  obj.evaluateGlobalFilterLikelihood( otherCameraGroundMeasurements, predictedSample );
                
                if  predLikelihood > prevLikelihood
                    gPredictedState(selectSample, 1:4) = predictedSample;
                end
            end
            
            % Iterate over every state and accept/reject
            parfor i = 1 : length( gPosteriorState )
                % Select a random sample
                selectSample = i;
                    
                predState = gPredictedState(selectSample, 1:obj.s_particleFilterStateDimension) ;
                prevState = transitionState(selectSample, 1:obj.s_particleFilterStateDimension) ;
                
                % Evaluate likelihoods
                prevLikelihood = max( realmin, obj.evaluateGlobalFilterLikelihood( otherCameraGroundMeasurements, prevState ) );
                predLikelihood = obj.evaluateGlobalFilterLikelihood( otherCameraGroundMeasurements, predState );           
                
                % Evaluate Priors
                priorPrev = 1; %mvnpdf( prevState, predState, R);
                priorPred = 1; %max( realmin, mvnpdf( predState, prevState, R) );
                
                % Find alpha parallel for global filter
                gAlphaParallel = min( 1, ( predLikelihood ./ prevLikelihood  ) .* ( priorPrev ./ priorPred  ) );
                
                if rand() <= gAlphaParallel
                    % Accept the Predicted State
                    gPosteriorState(i,:) = predState;
                    weightList(i)        = predLikelihood;
                else
                    % Accept the Previous State
                    gPosteriorState(i,:) = prevState;
                    weightList(i)        = prevLikelihood;
                end
            end
            
            % get the weighted average
            weightedSum = zeros(1, obj.s_particleFilterStateDimension);
            for i = 1 : length( gPosteriorState )
                weightedSum = weightedSum + gPosteriorState(i,:) .* weightList(i);
            end
            weightedAverage = weightedSum ./ sum(weightList);
            
            % get the updated posterior state
            updatedPosteriorState = repmat( weightedAverage, length( gPosteriorState ), 1);
            
            % Update the particle filter state matrix
            obj.m_globalParticleFilter.Update( updatedPosteriorState );
        end
        
        % Update the local particle filter
        function obj = UpdateLocalParticleFilter(  obj,...
                                                   otherObjectMeasurements,...
                                                   otherCameraGroundMeasurements )
              
            % Predict local particle filter
            obj.m_localParticleFilter.Predict(  obj.s_varianceX,...
                                                obj.s_varianceY,...
                                                obj.s_scaleVarianceX,...
                                                obj.s_scaleVarianceY );
                                            
            transitionState     = obj.m_localParticleFilter.transition( );
    
            % Update particle filters
            predictedState      = obj.m_localParticleFilter.GetPredictedState(); 

            
            assert( length( transitionState ) == length( predictedState )  );
            
            posteriorState      = zeros(  length( predictedState ), obj.s_particleFilterStateDimension );   
            
            % Define the sigma for the proposal density with the motion model
            sigma              = eye( obj.s_particleFilterStateDimension );
            sigma(1,1)         = obj.s_varianceX;
            sigma(2,2)         = obj.s_varianceY;
            sigma(3,3)         = obj.s_scaleVarianceX;
            sigma(4,4)         = obj.s_scaleVarianceY;
            
            R = chol( sigma );
            
            % Compute Average Posterior State of Global Filter and find
            % Interaction Alpha
            gPosteriorState = obj.m_globalParticleFilter.GetPosteriorState( );
            
            % initialize weights
            weightList = zeros( 1, length( posteriorState ) );

            % Iterate over every state and accept/reject
            if obj.m_occlusionCount <= 0
                % perform burn-in iterations
                for i = 1 : Target.s_numberOfBurninIteration
                    % randomly select a particle
                    selectSample = randi( length( predictedState ) );

                    % predict using the conditional motion model
                    predictedSample = ParticleFilter.PredictParticle( obj.s_varianceX,...
                                                                      obj.s_varianceY,...
                                                                      obj.s_scaleVarianceX,...
                                                                      obj.s_scaleVarianceY,... 
                                                                      predictedState(selectSample, 1:4) );

                    prevLikelihood =  obj.evaluateLocalFilterLikelihood( otherObjectMeasurements, predictedState(selectSample, 1:4));
                    predLikelihood =  obj.evaluateLocalFilterLikelihood( otherObjectMeasurements, predictedSample );
                    if  predLikelihood > prevLikelihood
                        predictedState(selectSample, 1:4) = predictedSample;
                    end
                end
                
                % set the predicted state
                obj.m_localParticleFilter.SetPredictedState( predictedState );
                
                % perform MCMC sampling
                parfor i = 1 : length( posteriorState )
                    
                    % Select a random sample
                    selectSample = i;
                    
                    % Calculate likelihoods
                    predState = predictedState(selectSample, 1:obj.s_particleFilterStateDimension) ;
                    prevState = transitionState(selectSample, 1:obj.s_particleFilterStateDimension) ;
 
                    % Evaluate likelihoods
                    prevLikelihood = max( realmin, obj.evaluateLocalFilterLikelihood( otherObjectMeasurements, prevState ) );
                    predLikelihood = obj.evaluateLocalFilterLikelihood( otherObjectMeasurements, predState );             
 
                    % Evaluate Priors
                    priorPrev = 1; %mvnpdf( prevState, predState, R );
                    priorPred = 1; %max( realmin, mvnpdf( predState, prevState, R) );
                    
                    % Parallel mode
                    if rand( ) >= obj.GAMMA
                        % Find alpha parallel for global filter
                        alphaParallel = min( 1, ( predLikelihood ./ prevLikelihood  ) .* ( priorPrev ./ priorPred  ) );
 
                        if rand( ) <= alphaParallel
                            % Accept the Predicted State
                            posteriorState( i, : )  = predState;
                            weightList(i)           = predLikelihood;
                        else
                            % Accept the Previous State
                            posteriorState( i, : )  = prevState;
                            weightList(i)           = prevLikelihood;
                        end
                    else
                        gPosteriorSample        = gPosteriorState(selectSample,1:obj.s_particleFilterStateDimension);
                        gPosteriorLikelihood    = obj.evaluateGlobalFilterLikelihood( otherCameraGroundMeasurements, gPosteriorSample);
                        lPosteriorLikelihood    = obj.evaluateLocalFilterLikelihood( otherObjectMeasurements, gPosteriorSample);;
                        
                        % Interaction Mode
                        alphaInteraction = gPosteriorLikelihood ./ (gPosteriorLikelihood + lPosteriorLikelihood);

                        if rand( ) <= alphaInteraction
                            posteriorState( i, : ) = gPosteriorSample;
                            weightList(i)          = gPosteriorLikelihood;
                        else
                            posteriorState( i, : ) = prevState;
                            weightList(i)          = prevLikelihood;
                        end
                    end
                end
            else 
                for i = 1 : length( posteriorState )
                    selectSample = randi( length( posteriorState ) );
                    
                    prevState = transitionState(i, 1:obj.s_particleFilterStateDimension) ;
                    gPosteriorSample        = gPosteriorState(selectSample,1:obj.s_particleFilterStateDimension);
                    
                    % Evaluate likelihoods
                    prevLikelihood          = max( realmin, obj.evaluateLocalFilterLikelihood( otherObjectMeasurements, prevState ) );
                    gPosteriorLikelihood    = obj.evaluateGlobalFilterLikelihood( otherCameraGroundMeasurements, gPosteriorSample);
                    lPosteriorLikelihood    = max( realmin, obj.evaluateLocalFilterLikelihood( otherObjectMeasurements, gPosteriorSample) );
                        
                    % Interaction Mode
                    alphaInteraction = gPosteriorLikelihood ./ (gPosteriorLikelihood + lPosteriorLikelihood);

                    if rand( ) <= alphaInteraction
                        posteriorState( i, : ) = gPosteriorSample;
                        weightList(i)          = gPosteriorLikelihood;
                    else
                        posteriorState( i, : ) = prevState;
                        weightList(i)          = prevLikelihood;
                    end
                end                
            end
            
            % get the weight average
            weightedSum = zeros(1, obj.s_particleFilterStateDimension);
            for i = 1 : length( posteriorState )
                weightedSum = weightedSum + posteriorState(i,:) .* weightList(i);
            end
            weightedAverage = weightedSum ./ sum(weightList);
            
            % get the updated posterior state
            updatedPosteriorState = repmat( weightedAverage, length( posteriorState ), 1);
            
            % Update the particle filter state matrix
            obj.m_localParticleFilter.Update( updatedPosteriorState );
        end
        
        % evaluate local filter likelihood
        function lkhd = evaluateLocalFilterLikelihood( obj,...
                                                       otherObjectMeasurements,...
                                                       X...% X is centroid in (x,y)
                                                     )            
            interactiveLkhd  = 1.0;
            
            % calculate interactive likelihood
            objW    = obj.m_width * X(3);
            objH    = obj.m_height * X(4);
            XRect   = int64([X(1) - objW/2 X(2) - objH/2 objW objH]);
 
            for i = 1 : size( otherObjectMeasurements, 1 )
                detDist = dist( double([XRect(1) XRect(2)]), otherObjectMeasurements(i,1:2)' );                    
                interactiveLkhd = interactiveLkhd .* (1- ( (1/obj.INTERACTIVE_NORMALIZATION_BETA) .* exp( - detDist / obj.INTERACTIVE_NORMALIZATION_SIGMA ) ) );
            end

            % calculate appearance likelihood
            localCenter = [obj.m_localObjRectangle(1) + obj.m_localObjRectangle(3)/2 obj.m_localObjRectangle(2)+obj.m_localObjRectangle(4)/2];
            appearanceLkhd = mvnpdf( double([X(1) X(2)]), [ localCenter(1) localCenter(2)], [ 2 2]);

            lkhd = appearanceLkhd * max( interactiveLkhd, 0.1 );
        end
        
        % Evaluate global filter likelihood
        function lkhd = evaluateGlobalFilterLikelihood( obj,...
                                                        otherCameraGroundMeasurements,...
                                                        X )
            multiCameraLikelihood   = 1.0;
            scenePrior              = 1.0;

            % calculate interactive likelihood
            objW = obj.m_width * X(3);
            objH = obj.m_height * X(4);
            XRect = int64([ (X(1)- objW/2)  (X(2)-objH/2) objW objH]);
            gpX  = Camera.ProjectToGroundPlane( double(XRect), obj.m_homographyMatrix, obj.m_cameraModel );
            for i = 1 : size( otherCameraGroundMeasurements, 1 )
                detDist = dist( [gpX(1) gpX(2)], otherCameraGroundMeasurements(i,:)' );                    
                multiCameraLikelihood = multiCameraLikelihood .* ( (1/obj.MC_NORMALIZATION_RHO) .* exp( - detDist / obj.MC_NORMALIZATION_SIGMA ) );
            end

            % calculate scene prior
            if ~isempty(obj.m_trajectoryDatabase)
                objH = obj.m_height * X(4);
                prevLoc     = [ obj.m_objRectangle(1)+obj.m_objRectangle(3)/2 obj.m_objRectangle(2)+ obj.m_objRectangle(4) ];
                curLoc      = [ X(1) X(2)+ objH/2 ];
                scenePrior  = obj.m_trajectoryDatabase.EvaluateDensity( prevLoc,...
                                                                        curLoc,...
                                                                        1 );
                assert( scenePrior >= 0 );
            end

            % calculate appearance likelihood
            % Note x is column index and y is row index
            globalCenter = [obj.m_globalObjRectangle(1) + obj.m_globalObjRectangle(3)/2 obj.m_globalObjRectangle(2)+obj.m_globalObjRectangle(4)/2];
            appearanceLkhd = mvnpdf( double([X(1) X(2)]), [ globalCenter(1) globalCenter(2)], [ 2 2]);
            
            lkhd = appearanceLkhd * max( multiCameraLikelihood, 0.1 ) * max( scenePrior, 0.1 );
        end
        
        % Update object rectangle with the posterior
        function UpdateObjectRectangleWithPosterior( obj )
            
            localParticleState  = obj.m_localParticleFilter.GetAverageParticle();
            objW                = obj.m_width  * localParticleState(3);
            objH                = obj.m_height * localParticleState(4);
                  
            objRect             = [ localParticleState(1) - objW/2 localParticleState(2) - objH/2 objW objH ];
            obj.m_objRectangle      =  Target.GetValidBoundingBox( objRect, obj.m_imageResolution(2), obj.m_imageResolution(1) );
            obj.m_trackingResults   = [ obj.m_trackingResults; obj.m_objRectangle ];
            
            obj.m_groundPlaneTrajectoryHistory  = [ obj.m_groundPlaneTrajectoryHistory;...
                                                    Camera.ProjectToGroundPlane( obj.m_objRectangle, obj.m_homographyMatrix, obj.m_cameraModel )];
                                                
            obj.m_imagePlaneTrajectoryHistory   = [ obj.m_imagePlaneTrajectoryHistory;...
                                                    obj.m_objRectangle]; % Trajectory history on the image plane

        end
        
        % Update the Appearance model using Ensemble classifier
        function obj = UpdateLocalAppearanceModel( obj,...
                                                   frameImage )
            assert( nargin >= 2 );
            if ( obj.IsActive( ) )
                
                assert( ~isempty(frameImage) );
                   
                [ obj.m_localClassifier ]   = obj.m_localClassifier.Update( frameImage,...
                                                                            obj.m_objRectangle );                
            end
        end
        
        % Update the Appearance model using Ensemble classifier
        function obj = UpdateGlobalAppearanceModel( obj,...
                                                    frameImage,...
                                                    otherViewTrainingSamples )
            assert( nargin >= 2 );
            if ( obj.IsActive( ) )
                
                assert( ~isempty(frameImage) );
                   
                [ obj.m_globalClassifier ]   = obj.m_globalClassifier.MultiViewUpdate( frameImage,...
                                                                                       obj.m_objRectangle,...
                                                                                       otherViewTrainingSamples );                
            end
        end
        
        % Get the positive training examples
        function trainingSamples = GetGlobalPositiveTrainingSamples( obj )
            trainingSamples = [];
            if ( obj.IsActive( ) )
                trainingSamples = obj.m_globalClassifier.GetPositiveTrainingSamples();        
            end
        end
        
        % Get the training examples
        function trainingSamples = GetGlobalTrainingSamples( obj )
            trainingSamples = [];
            if ( obj.IsActive( ) )
                trainingSamples = obj.m_globalClassifier.GetTrainingSamples();        
            end
        end
 
    end%methods public
 
    methods( Access = private )
          
        % Check region of Interest
        obj = CheckRegionOfInterest( obj, frameImage );
        
    end%methods private
 
    methods(Static)
        % get the VOC score
        function vocScore = GetVOCScore( rect1, rect2 )
            interArea = rectint( rect1, rect2 );
            area1    = rect1(3) * rect1(4);
            area2    = rect2(3) * rect2(4);
            vocScore = interArea ./ ( area1 + area2 - interArea );
        end          
        
        % crop image for calculating histogram
        function Id =  cropImage( I, Bd, imWidth, imHeight )
            Bd = Target.GetValidBoundingBox( Bd, imWidth, imHeight );
            Id = I( Bd(2) : Bd(2) + Bd(4), Bd(1) : Bd(1) + Bd(3), : );
        end
        
        % validate bounding box
        function Bd = GetValidBoundingBox( Bd, imWidth, imHeight )
 
           if Bd(1) < 1
                dStartX = 1;
            elseif Bd(1) > imWidth
                dStartX = imWidth;
            else
                dStartX = Bd(1);
           end
 
            if Bd(2) < 1
                dStartY = 1;
            elseif Bd(2) > imHeight
                dStartY = imHeight;
            else
                dStartY = Bd(2);
            end
 
            
            if ( Bd(1) + Bd(3) ) > imWidth
                wD = max( imWidth -  Bd(1), 0 );
            elseif ( Bd(1)+Bd(3) ) < 1
                wD = 0;
            else
                wD = Bd(3);
            end
            
            if ( Bd(2)+Bd(4) ) > imHeight
                hD = max( imHeight -  Bd(2), 0);
            elseif ( Bd(2) + Bd(4) ) < 1
                hD = 0;
            else
                hD = Bd(4);
            end
                
            posD = [ dStartX  dStartY ];
            
            Bd = double([ posD wD hD ]); 
        end
 
    end%static methods
 
end%classdef

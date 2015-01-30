%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This class implements the Ensemble Classifier
%
%   Reference:
%       "Ensemble Tracking" - Avidan, S.
%
%   Author  -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef EnsembleClassifier < handle
    
    properties(GetAccess = 'public', SetAccess = 'private')
        
        m_numberOfWeakClassifiers;              % number of weak classifiers
        m_numberOfWeakClassifiersChanged;       % number of weak classifiers changed at each time instance
        
        m_foregroundRegionMask;                 % foreground mask of the object from which positive training samples are generated
        m_backgroundRegionMask;                 % background mask of the object from which positive training samples are generated
        
        m_featureType;                          % RAW_COLOR or HOG
        m_trainingFeature;                      % training feature samples
        m_testingFeature;                       % testing feature samples
        
        m_trainingLabels;                       % training labels
        
        m_foregroundBackgroundShuffleIndices;   % shuffle, sorted for training
        m_numberOfRowsForBoosting;              % number of rows in ROI
        m_numberOfColumnsForBoosting;           % number of columns in ROI
        
        m_weakClassifiers;                      % weak classifier struct            
    end%properties

    properties( Constant )
        NUMBER_BEST_WEAK_CLASSIFIERS_TO_SHARE   = 3;
        POSITIVE_SAMPLE_SELECTION_THRESHOLD     = 0.8;
    end%constant properties

    methods( Access = public )
        
        function obj = EnsembleClassifier(  initializationImageFrame,...
                                            objectRectangle,...
                                            numberOfWeakClassifiers,...
                                            numberOfWeakClassifiersChanged,...
                                            featureType,...
                                            featureOptions,...
                                            drOptions )
                                        
            assert( nargin ==  7 );
            assert( numberOfWeakClassifiers > 0 && numberOfWeakClassifiersChanged >= 0 );
            assert( numberOfWeakClassifiers >= numberOfWeakClassifiersChanged );
            assert( ~isempty( featureType ) );
            
            obj.m_numberOfWeakClassifiers           = numberOfWeakClassifiers;
            obj.m_numberOfWeakClassifiersChanged    = numberOfWeakClassifiersChanged;
            obj.m_featureType                       = featureType;
            
            obj.m_trainingFeature                   = Features( featureType, featureOptions, drOptions );
            obj.m_testingFeature                    = Features( featureType, featureOptions, drOptions );
            
            % initialize image frame
            obj                                     = obj.Initialize( initializationImageFrame,...
                                                                      objectRectangle );
        
        end
        
        % initialize the ensemble classifier
        obj = Initialize(   obj,...
                            initializationImageFrame,...
                            objectRectangle );
        
        % update the ensemble classifier
        [ obj, objectRectangle ] = Update( obj,...
                                           frameImage,...
                                           trainingRectangle );
               
        % update ensemble classifier with features from multiple views
        [ obj, objectRectangle ] =  MultiViewUpdate( obj,...
                                                     initializationImageFrame,...
                                                     objectRectangle,...
                                                     otherViewTrainingSamples );
        
        % test the classifier on a given image
        [ obj, currentLocation, confidenceMap ] = Test( obj,...
                                                        frameImage,...
                                                        previousTargetRectangle,...
                                                        isParticleFilterEnabled );
        
        % prepare foreground and background masks 
        [ obj, objectRectangle ] = PrepareForegroundAndBackgroundMasks( obj,...
                                                                        frameImage,...
                                                                        objectRectangle,...
                                                                        phase );
        
        % extract features on a given image
        obj = ExtractFeatures( obj,...
                               inputImage,...
                               phase );
                           
        % get best performing weak classifiers
        weakClassifierList = GetBestPerformingWeakClassifiers( obj );
        
        % get negative examples
        negativeSamples = GetNegativeSamplesForCorrelatedObjects( obj, weakClassifierList );
        
        % get positive examples
        function positiveSamples = GetPositiveTrainingSamples( obj )
            positiveLabelIndex  = obj.m_trainingLabels == 1;
            featurevector       = obj.m_trainingFeature.GetFeatureVector( );
            positiveSamples     = featurevector( :,  positiveLabelIndex );
        end
        
        % get training samples
        function trainingSamples = GetTrainingSamples( obj )
            trainingSamples = obj.m_trainingFeature.GetFeatureVector( );
        end
        
    end%methods public
    

    methods( Access = private )

    end%methods private

    methods(Static)

    end%static methods
   
end%classdef
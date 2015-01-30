%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    This function initializes Ensemble Classifier.
%
%   Input --
%       @obj -                      - Ensemble Classifier Object 
%       @initializationImageFrame   - Input Image
%       @objectRectangle            - object rectangle
%
%   Output -- 
%       @obj        - EnsembleClassifier object
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = Initialize(  obj,...
                            initializationImageFrame,...
                            objectRectangle )
        
    try
        obj = obj.PrepareForegroundAndBackgroundMasks(  initializationImageFrame,...
                                                        objectRectangle );

        obj = obj.ExtractFeatures(  initializationImageFrame,...
                                    'TRAIN' );

        assert( ~isempty( obj.m_trainingFeature.GetFeatureVector() ) );
        assert( ~isempty( obj.m_trainingLabels ) );
        
        trainingFeatures = obj.m_trainingFeature.GetFeatureVector();
        trainingLabels   = obj.m_trainingLabels;
        
        drOptions = obj.m_trainingFeature.GetDimensionalityReductionOptions( );
        
        if drOptions.enabled
            X1 = trainingFeatures';% apply pca
            [U1, mu1, ~] = pca(X1);
            [ S1, ~, ~ ] = pcaApply( X1, U1, mu1, drOptions.d );
            trainingFeatures = S1 * trainingFeatures;
        end

        obj.m_weakClassifiers = gentleBoost( trainingFeatures,...
                                             trainingLabels,...
                                             obj.m_numberOfWeakClassifiers...
                                            );

        assert( ~isempty( obj.m_weakClassifiers ) );
        
    catch ex
        throwAsCaller( ex );
    end
                            
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function tests the Ensemble Classifier on the given test image
%
%   Input --
%       @obj -                      - Ensemble Classifier Object 
%       @frameImage                 - Input Image
%       @previousTargetRectangle    - object rectangle
%       @isParticleFilterEnabled    - is particle filter enabled
%
%   Output -- 
%       @obj                        - EnsembleClassifier object
%       @currentRectangle           - Current Target Rectangle
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ obj, currentRectangle, fgConfidenceMap ] = Test( obj,...
                                                            frameImage,...
                                                            previousTargetRectangle,...
                                                            isParticleFilterEnabled )
        
    assert( nargin >= 3 );
    assert( ~isempty(frameImage) );

    if isParticleFilterEnabled 
        [  obj, previousTargetRectangle ] = obj.PrepareForegroundAndBackgroundMasks( frameImage, previousTargetRectangle, 'TEST' );
    else
        [  obj, previousTargetRectangle ] = obj.PrepareForegroundAndBackgroundMasks( frameImage, previousTargetRectangle, 'TRAIN' );
    end

    currentRectangle = previousTargetRectangle;

    % Extract features for testing
    obj = obj.ExtractFeatures( frameImage, 'TEST' );

    assert( ~isempty( obj.m_testingFeature.GetFeatureVector() ) );
    
    testingFeatures = obj.m_testingFeature.GetFeatureVector();

    drOptions = obj.m_testingFeature.GetDimensionalityReductionOptions( );
   
    if drOptions.enabled
        X1 = testingFeatures';% apply pca
        [U1, mu1, ~] = pca(X1);
        [ S1, ~, ~ ] = pcaApply( X1, U1, mu1, drOptions.d );
        testingFeatures = S1 * testingFeatures;
    end


    % Run the learned classifier on the test features.
    [Cx, Fx, weakOutput ] = strongGentleClassifier( testingFeatures,...
                                                    obj.m_weakClassifiers );
              
    % Find the mode using mean shift
    confidenceMap = reshape( Cx, uint32( [ obj.m_numberOfRowsForBoosting obj.m_numberOfColumnsForBoosting ] ) ); 
    [tracker_y tracker_x] = find( confidenceMap == 1);
    
    fgConfidenceMap = zeros( size(frameImage,1), size(frameImage,2) );
    backgroundForegroundMask = [obj.m_backgroundRegionMask; obj.m_foregroundRegionMask];

    %use the sigmoid of the classifier response as the confidence
    fgConfidenceMap( backgroundForegroundMask( obj.m_foregroundBackgroundShuffleIndices ) ) = 1 ./ (1 + exp(-Fx) );

    maxConfidence = max(max(fgConfidenceMap));
    minConfidence = min(min(fgConfidenceMap));
    threshold     = (maxConfidence - minConfidence) * 0.5;
    fgConfidenceMap(find(fgConfidenceMap < threshold))=0;

    if ( numel(tracker_y) < 10 ),
        display(['Tracker for has failed this pass']);
        return;
    end

    mode = meanshiftSpatial( [ tracker_x(:)'; tracker_y(:)' ],...
                             8,...
                             .5,... 
                            [ obj.m_numberOfColumnsForBoosting/2 obj.m_numberOfRowsForBoosting/2]' );

    meanShift = mode - [obj.m_numberOfColumnsForBoosting/2 obj.m_numberOfRowsForBoosting/2 ]';

    currentRectangle(1) = ceil( previousTargetRectangle(1) + meanShift(1) );
    currentRectangle(2) = ceil( previousTargetRectangle(2) + meanShift(2) ); 
end
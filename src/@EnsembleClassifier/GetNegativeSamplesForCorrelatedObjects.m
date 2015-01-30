%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function extracts negative examples that are consistent 
%   across views
%
%   Input --
%       @obj                    - Ensemble Classifier Object 
%       @weakClassifierList     - weak classifier list
%
%   Output -- 
%       @negativeSamples        - Negative samples for the other objects
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function correlatedNegativeSamples = GetNegativeSamplesForCorrelatedObjects( obj,...
                                                                             weakClassifiers )
                                                                         
    assert( ~isempty(weakClassifiers) );
    
    positiveLabelIndex = find(obj.m_trainingLabels == 1);
    featurevector = obj.m_trainingFeature.GetFeatureVector( );
    
    positiveFeatureVector = featurevector( :,  positiveLabelIndex );
    
    
    sharedWeakClassifierList = cell( length( weakClassifiers ), 1 );
    for i = 1 : length( weakClassifiers )
        sharedWeakClassifierList{i} = weakClassifiers(i);
    end
    
    [~, Fx ] = strongGentleClassifier( positiveFeatureVector,...
                                       sharedWeakClassifierList );
                                                
    strongPositiveFeatureIndex = find( 1 ./ (1 + exp(-Fx) ) > EnsembleClassifier.POSITIVE_SAMPLE_SELECTION_THRESHOLD );
    correlatedNegativeSamples = positiveFeatureVector( :, strongPositiveFeatureIndex );
end
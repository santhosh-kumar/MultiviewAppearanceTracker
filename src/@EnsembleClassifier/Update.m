%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    This function updates the Ensemble Classifier on the given training
%    image
%
%   Input --
%       @obj -                      - Ensemble Classifier Object 
%       @frameImage                 - Input Image
%       @objectRectangle            - object rectangle
%
%   Output -- 
%       @obj                        - EnsembleClassifier object
%       @objectRectangle            - Current Target Rectangle
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ obj, objectRectangle ] = Update( obj,...
                                            frameImage,...
                                            objectRectangle )
        
    assert( nargin == 3 );
    assert( ~isempty(frameImage) );
    assert( ~isempty(objectRectangle) );
    
    [ obj, objectRectangle ] = obj.PrepareForegroundAndBackgroundMasks( frameImage,...
                                                                        objectRectangle,...
                                                                        'TRAIN' );

    obj = obj.ExtractFeatures( frameImage, 'TRAIN' );

    assert( ~isempty( obj.m_trainingFeature.GetFeatureVector() ) );
    assert( ~isempty( obj.m_trainingLabels ) );

    error = zeros( numel( obj.m_weakClassifiers), 3 );
    for iter = 1 : numel( obj.m_weakClassifiers )
        error(iter,1)   = obj.m_weakClassifiers{iter}.err;
        error(iter,2)   = obj.m_weakClassifiers{iter}.pos_err;
        error(iter,3)   = obj.m_weakClassifiers{iter}.neg_err;
    end

    [ ~, pick_class_index ] = sort( error(:,1), 'ascend' );

    % Reordering classifiers in ascending order according to error ...
    for iter= 1 : numel( obj.m_weakClassifiers ) 
        ensembleSort{iter} = obj.m_weakClassifiers{ pick_class_index(iter) };
    end
    
    trainingFeatures    = obj.m_trainingFeature.GetFeatureVector();
    traningLabels       = obj.m_trainingLabels;
    
    drOptions = obj.m_trainingFeature.GetDimensionalityReductionOptions( );
        
    if drOptions.enabled
        X1 = trainingFeatures';% apply pca
        [U1, mu1, ~] = pca(X1);
        [ S1, ~, ~ ] = pcaApply( X1, U1, mu1, drOptions.d );
        trainingFeatures = S1 * trainingFeatures;
    end

    
    % Train the appearance model
    obj.m_weakClassifiers = ensemble_update(    trainingFeatures,...
                                                traningLabels,...
                                                obj.m_numberOfWeakClassifiers,...
                                                ensembleSort,...
                                                obj.m_numberOfWeakClassifiersChanged ); 

    assert( ~isempty( obj.m_weakClassifiers ) );
end
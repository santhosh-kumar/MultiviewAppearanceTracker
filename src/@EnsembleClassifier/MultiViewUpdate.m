%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function updates the classifier with training samples from
%   multiple views
%
%   Input -- 
%    @frameImage               - frame image
%    @objectRectangle          - ROI rectangle
%    @otherViewTrainingSamples - training samples from other views
%
%   Output -- 
%       @obj                - measurement matrix
%       @objectRectangle    - valid region of interest rectangle
%
%   Author  -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[ obj, objectRectangle ] =  MultiViewUpdate( obj,...
                                                     frameImage,...
                                                     objectRectangle,...
                                                     otherViewTrainingSamples )
                                                 
                                              
    assert( nargin == 4 );
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
    trainingLabels      = obj.m_trainingLabels;
       
    [ trainingFeatures, trainingLabels] = AppearanceModel.SampleFromGenerativeSubspace( trainingFeatures,...
                                                                                        trainingLabels,...
                                                                                        otherViewTrainingSamples,...
                                                                                        obj.m_trainingFeature.GetDimensionalityReductionOptions( ) );
    
    
%     if ~isempty( otherViewTrainingSamples )
%         for i = 1 : length( otherViewTrainingSamples )
%             trainingSamples = otherViewTrainingSamples{i};
%             
%             if ~isempty(trainingSamples)
%                 trainingFeatures = [ trainingFeatures trainingSamples ];
%                 trainingLabels    = [ traningLabels ones( 1, size( trainingSamples, 2 ) ) ];
%             end
%         end
%     end
%     
    assert( size(trainingFeatures,2) == size(trainingLabels,2) );

    % Train the appearance model
    obj.m_weakClassifiers = ensemble_update( trainingFeatures,...
                                             trainingLabels,...
                                             obj.m_numberOfWeakClassifiers,...
                                             ensembleSort,...
                                             obj.m_numberOfWeakClassifiersChanged ); 

    assert( ~isempty( obj.m_weakClassifiers ) );                                         
end
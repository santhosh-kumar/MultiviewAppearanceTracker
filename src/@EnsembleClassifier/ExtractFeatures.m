%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    This function extracts features on the given image and stores it 
%    in the appropriate variable
%
%   Input --
%       @obj -      - Ensemble Classifier Object 
%       @inputImage - Input Image
%       @phase      - TRAIN or TEST phase.
%   Output -- 
%       @obj        - EnsembleClassifier object
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = ExtractFeatures( obj,...
                               inputImage,...
                               phase )

    assert( nargin == 3 );
    assert( ~isempty( inputImage ) );

    % clear the labels from previous training
    if ( strcmp( phase, 'TRAIN' ) )
        obj.m_trainingLabels    = [];
        obj.m_trainingFeature   = obj.m_trainingFeature.ResetFeatures();
    else
        assert( strcmp( phase, 'TEST' ) );
        obj.m_testingFeature    = obj.m_testingFeature.ResetFeatures( );
    end
    
    %Note: Always store the background features first and then the foreground, because the shuffle index is based on this order
    
    labelSet = [ -1 1];
    % for each label in the label set
    for label = labelSet

        if ( label == -1 )  
            %negative labels( background )
            roiMASK = obj.m_backgroundRegionMask;
        elseif ( label == 1 ) 
            %positive labels( foreground )
            roiMASK = obj.m_foregroundRegionMask;
        end

        if label == 1
            % concatenate with the currently obtained features for this training phase
            shouldConcatenateWithExistingFeatures = 1;
        else
            shouldConcatenateWithExistingFeatures = 0;
        end
        
        if ( strcmp( phase, 'TRAIN' ) )
            
            obj.m_trainingFeature = obj.m_trainingFeature.ExtractFeatures( inputImage,...
                                                                           roiMASK,...
                                                                           shouldConcatenateWithExistingFeatures );
                                                     
            % update the labels for training - concatenate labels to the existing labels
            obj.m_trainingLabels = [ obj.m_trainingLabels label * ones( 1, numel(roiMASK) ) ];
            
        else
            
            obj.m_testingFeature = obj.m_testingFeature.ExtractFeatures( inputImage,...
                                                                         roiMASK,...
                                                                         shouldConcatenateWithExistingFeatures );
        end
    end

    % shuffle the features and labels for a robust training
    if strcmp( phase, 'TRAIN' )
        obj.m_trainingFeature    = obj.m_trainingFeature.ShuffleFeatures( obj.m_foregroundBackgroundShuffleIndices );
        obj.m_trainingLabels     = obj.m_trainingLabels( obj.m_foregroundBackgroundShuffleIndices );
    else
        obj.m_testingFeature     = obj.m_testingFeature.ShuffleFeatures( obj.m_foregroundBackgroundShuffleIndices );
    end

end
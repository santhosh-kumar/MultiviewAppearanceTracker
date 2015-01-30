%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    This function updates the Ensemble Classifier on the given training
%    image
%
%   Input --
%       @trainingFeatures           - Training Features
%       @trainingLabels             - Training Labels
%       @otherViewTrainingSamples   - Other view training samples
%       @drOptions                  - Dimensionality Reduction Options
%
%   Output -- 
%       @sampledTrainingFeatures    - Training Features Sampled from GS
%       @sampledTrainingLabels      - Sampled Training Labels
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    This function updates the Ensemble Classifier on the given training
%    image
%
%   Input --
%       @trainingFeatures           - Training Features
%       @trainingLabels             - Training Labels
%       @otherViewTrainingSamples   - Other view training samples
%       @drOptions                  - Dimensionality Reduction Options
%
%   Output -- 
%       @sampledTrainingFeatures    - Training Features Sampled from GS
%       @sampledTrainingLabels      - Sampled Training Labels
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ sampledTrainingFeatures, sampledTrainingLabels] = SampleFromGenerativeSubspace( trainingFeatures,...
                                                                                           trainingLabels,...
                                                                                           otherViewTrainingSamples,...
                                                                                           drOptions )
                                                                          
    assert( nargin == 4 );

    t = [0.25 0.5 0.75];
    
    X1 = trainingFeatures';% apply pca
    [U1, mu1, ~] = pca(X1);
    [ S1, ~, ~ ] = pcaApply( X1, U1, mu1, drOptions.d );
    S1 = S1'; % n x d
    
    sampledTrainingFeatures = S1'*trainingFeatures;
    sampledTrainingLabels   = trainingLabels;
   
    
    X1a = cell( length( otherViewTrainingSamples ), length(t) );
    
    for i = 1 : length( otherViewTrainingSamples )
        X2 = otherViewTrainingSamples{i}';
        
        if ~isempty(X2)
            [U2, mu2, ~] = pca(X2);
            [ S2, ~, ~ ] = pcaApply( X2, U2, mu2, drOptions.d );
            S2 = S2'; % n x d

            % compute the direction and speed of geodesic flow
            A = compute_velocity_grassmann_efficient(S1, S2); %(n-d) x d
            
            for j = 1 : length(t)
                S1a = compute_Y_havingVelocity( S1, A, t(j));
                X1a{i,j} = S1a' * X1';

                sampledTrainingFeatures = [sampledTrainingFeatures X1a{i,j}];
                sampledTrainingLabels   = [sampledTrainingLabels  trainingLabels];
            end

        end        
    end
end
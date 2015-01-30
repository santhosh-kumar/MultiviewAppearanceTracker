%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This class implements MCMC based particle filter.
%
%   Reference:
%       MCMC-Based Particle Filtering for Tracking a
%       Variable Number of Interacting Targets
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef ParticleFilter < handle

    properties(GetAccess = 'public', SetAccess = 'private')
       
        m_numberOfParticles;
        m_objectRectangle;
        m_imageHeight;
        m_imageWidth;
        
        m_timeIndex;
        m_maxScaleChange;
        m_minScaleChange;
        m_maxScaleChangeInOneInterval;
        
        m_stateDimension;
        m_stateMatrix;                  %[ centerX, centerY, scaleX, scaleY, weight ]
        m_predictedStateMatrix;         %[ centerX, centerY, scaleX, scaleY ]
        m_originalStateMatrix;          %[ centerX, centerY, scaleX, scaleY ]
        
        m_LikelihoodCallBackFunction;
        
    end % properties

    properties(Constant)
        NUMBER_OF_PARTICLES_TO_DISPLAY = 10;
        A1 = 2;
        A2 = -1;
        B0 = 1.0;
        
        TRANS_X_STD  =  8;
        TRANS_Y_STD  =  6;
        TRANS_SX_STD =  0.001;
        TRANS_SY_STD =  0.001;
    end % constant properties

    methods( Access = public )

        % constructor
        function obj = ParticleFilter(  numberOfParticles,...
                                        objectRectangle,...
                                        imageHeight,...
                                        imageWidth,...
                                        particleStateDimension )
            try
                assert( nargin == 5 );

                % Set the initial parameters for particle filter.
                obj.m_numberOfParticles      = numberOfParticles;
                obj.m_objectRectangle        = objectRectangle;
                obj.m_imageHeight            = imageHeight;
                obj.m_imageWidth             = imageWidth;
                obj.m_stateDimension         = particleStateDimension;
                obj.m_timeIndex              = 0;
                obj.m_stateMatrix            = zeros( numberOfParticles, particleStateDimension + 1 );
                obj.m_predictedStateMatrix   = zeros( numberOfParticles, particleStateDimension );
                obj.m_originalStateMatrix    = zeros( numberOfParticles, particleStateDimension );
            catch ex
                error( [ 'Failed to construct particle Filter:' ex ] );
            end
        end

        % initialize the particle filter
        obj = Initialize(  obj,...
                           centerX,...
                           centerY,...
                           scaleX,...
                           scaleY,...
                           maxScaleChangeInOneInterval,...
                           maxScaleChange,...
                           minScaleChange );

        % predict the state with brownian motion
        obj = Predict(  obj,...
                        standardDeviationX,...
                        standardDeviationY,...
                        standardDeviationScaleX,...
                        standardDeviationScaleY,...
                        currentWidth,...
                        currentHeight );
        
        
        % update the state matrix
        obj = Update( obj,...
                      posteriorStateMatrix );
                  
         
        % transition particles according to the transition model
        transitionStateMatrix = transition( obj );

                 
        %displayParticles on the image plane
        DisplayParticles( obj, imageFrame );
                
        % Getters
        function weightList = GetWeightList( obj )
            weightList = obj.m_stateMatrix(:, obj.m_stateDimension+1 );
        end
        
        % Get particle for the given index
        function particle = GetParticle( obj, index )
            particle = obj.m_stateMatrix( index, 1 : 4 );
        end
        
        % Set Particle for the given index
        function obj = SetParticle( obj, index, particle )
            obj.m_stateMatrix(index, 1:obj.m_stateDimension) = particle;
        end
        
        % Set predicted particle matrix
        function obj = SetPredictedState( obj, predictedParticleMatrix )
            obj.m_predictedStateMatrix = predictedParticleMatrix;
        end
        
        % Get Number of Particles
        function numberOfParticles = GetNumberOfParticles( obj )
           numberOfParticles = obj.m_numberOfParticles;
        end
        
        %Get Average Particle
        function averageParticle = GetAverageParticle( obj )
            averageParticle = mean( obj.m_stateMatrix, 1);
        end
        
        %Get top N particles
        function [ particleList, sortedWeightList] = GetTopNParticles( obj, N )
            assert( N > 0 );
            
            weightList = obj.GetWeightList( );
            [ sortedWeightList, sortedIndex ] = sort( weightList, 1, 'descend' );
            
            sortedWeightList = sortedWeightList(1:N);
            assert( ~isempty(obj.m_stateMatrix) );
            
            particleList = obj.m_stateMatrix( sortedIndex(1:N), 1:obj.m_stateDimension );
       
            assert( ~isempty(particleList) );
        end
        
        
        function averageParticle = GetAverageTopNParticles( obj, N )
            assert( N > 0 );
            
            [ particleList, weightList] = obj.GetTopNParticles( N );
            
            averageParticle = zeros( 1, 4 );
            
            
            for i = 1 : N
                averageParticle = averageParticle + particleList(i, :) * weightList(i);
            end
            
            averageParticle =  averageParticle ./ sum(weightList);            
        end
        
        % Setters
        function obj = SetWeights( obj,...
                                   weightList )
            assert( length(weightList) == obj.m_numberOfParticles );
            obj.m_stateMatrix( :, obj.m_stateDimension+1 ) =  weightList;
        end
        
        % Set the weight
        function obj = SetWeight( obj,...
                                  weight,...
                                  index )
            assert( index <= obj.GetNumberOfParticles() );
            assert( weight >= 0  && weight <= 1);
            obj.m_stateMatrix( index, obj.m_stateDimension+1 ) = weight;
        end
        
        % get the predicted state matrix
        function predictedStateMatrix = GetPredictedState( obj )
            predictedStateMatrix = obj.m_predictedStateMatrix;
        end
        
        % get the posterior state
        function  posteriorStateMatrix = GetPosteriorState( obj )
            posteriorStateMatrix = obj.m_stateMatrix;
        end
        
        % get the initial width and height
        function [w,h] = GetInitialWidthHeight( obj )
            w = obj.m_objectRectangle(3);
            h = obj.m_objectRectangle(4);
        end
    
    end%methods public

    methods( Access = private )
        
        %Normalize particle weights
        function NormalizeParticleWeights( obj )
        
            weightList = obj.GetWeightList();
            
            normalizedWeightList = weightList ./ sum( weightList );
            
            % assign equals weights if all the weights are zero
            if sum( normalizedWeightList ) > 0 
                obj.m_stateMatrix( :, obj.m_stateDimension+1 ) = normalizedWeightList;
            else
                obj.m_stateMatrix( :, obj.m_stateDimension+1 ) = ones( obj.m_numberOfParticles, 1 );
            end
        end
        
    end%methods privates

    methods(Static)
        % predict a single particle
        particle = PredictParticle( varianceX,...
                                    varianceY,...
                                    varianceScaleX,...
                                    varianceScaleY,...
                                    particle );
    end%static methods
end%classdef
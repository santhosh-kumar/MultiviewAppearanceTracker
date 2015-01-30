%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Features class computes the image features based on the specified type
%
%   Author -- Santhoshkumar Sunderrajan
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef Features < handle
    
   properties(GetAccess = 'public', SetAccess = 'private')
       
       m_featureVector;     % stores the computed features
       m_featureType;       % type of the feature eg.colorHistogram, HOG, pHOG
       m_drOptions;        % options for dimensionality reduction
       m_featureOptions;    % options for feature calculations
       
   end% properties
   
   methods
       
       % Constructor
        function obj = Features( featureType, featureOptions, drOptions )
           assert( nargin == 3 );
           obj.m_featureVector  = [];
           obj.m_featureType    = featureType;
           obj.m_drOptions      = drOptions;
           obj.m_featureOptions = featureOptions;
        end
        
        % Extract Features
        function obj = ExtractFeatures( obj,...
                                        inputImage,...
                                        roiMask,...
                                        shouldConcatenateWithExistingFeatures,...
                                        isVectorized,...
                                        numberOfBins )
                                    
            if ( strcmp( obj.m_featureType, 'MULTI_DIMENSIONAL_COLOR_HISTOGRAM' ) )
                
                assert( nargin  == 6 );
                
                obj = ExtractColorHistogramFeature( obj,...
                                                    imageBlock,...
                                                    isVectorized,...
                                                    numberOfBins,...
                                                    roiMask );
                
            elseif ( strcmp( obj.m_featureType, 'RAW_COLOR' ) )
                
                obj  = ExtractRawColorFeatures( obj,...
                                                inputImage,...
                                                roiMask,...
                                                shouldConcatenateWithExistingFeatures );
                
            elseif ( strcmp( obj.m_featureType, 'HOG' ) || strcmp( obj.m_featureType, 'HOG_AND_COLOR' ) )
                
                obj = ExtractHOGFeatures(   obj,...
                                            inputImage,...
                                            roiMask,...
                                            shouldConcatenateWithExistingFeatures );    
            else
                error( 'Unsupported Feature Type' );
            end              
                                    
        end
                          
        % Get the feature vector - feature vector has to be computed before calling this method
        function featureVector = GetFeatureVector( obj )
            assert( ~isempty( obj.m_featureVector ) );            
            featureVector = obj.m_featureVector;
        end
        
        % Get dimensionality reduction options
        function drOptions = GetDimensionalityReductionOptions( obj )
           drOptions = obj.m_drOptions; 
        end
        
        % Reset the feature vector
        function obj = ResetFeatures( obj )
            obj.m_featureVector = [];
        end
        
        % Shuffle features
        function obj = ShuffleFeatures( obj, shuffleIndices )
            assert( nargin ==2 && ~isempty(shuffleIndices) );
            assert( ~isempty( obj.m_featureVector ) );
            obj.m_featureVector = obj.m_featureVector( :, shuffleIndices );
        end
        
        
   end% methods
   
   methods( Access = private )
       
        % Extracts raw color features.
        obj  = ExtractRawColorFeatures( obj,...
                                        inputImage,...
                                        roiMASK,...
                                        shouldConcatenateWithExistingFeatures );
                                   
        % Extracts HOG features
        obj = ExtractHOGFeatures( obj,...
                                  inputImage,...
                                  roiMASK,...
                                  shouldConcatenateWithExistingFeatures );
                            
        % Extracts multi-dimensional color histogram feature.
        obj = ExtractColorHistogramFeature( obj,...
                                            imageBlock,...
                                            isVectorized,...
                                            numberOfBins,...
                                            imageROI );
   end
   
   methods(Static)
       
        % Normalize the feature based on the range provided.
        function features = NormalizeFeatures( features, dynamicRange, origin )
        
            assert( nargin >= 2);
        
            features = double(features);
            shift_val = mean(dynamicRange);
            
            if ( origin )
                features = (features - shift_val)./dynamicRange(2) * 2;   
            else
                features = (features)./dynamicRange(2);
            end

            %features = features./repmat(sum(features,1),3,1);
        end

        % Computes bhattacharya distance between two histograms
        function bhattacharyaDistance = BhattacharyaDistance( hist1, hist2 )
           bhattacharyaDistance = sum( sqrt( hist1 .* hist2 ) );
        end

        % Calculate multidimensional color histogram
        multiDimensionalColorHistogram = GetMultiDimensionalColorHistogram( I,...
                                                                            isVectorized,...
                                                                            numberOfBins,...
                                                                            imageROI );

        % Generate raw color features
        function colorFeatureVector = GenerateRawColorFeatures( inputImage, roiMask )
        
            assert( nargin >= 2 );
            assert( ~isempty(inputImage) );
            assert( ~isempty(roiMask) );
            
            [ numberOfRows, numberOfColumns, numberOfChannels ] = size( inputImage );

            inputImage = double( ( inputImage ) );
            hsvImage   = rgb2hsv( inputImage );
            ycbcrImage = rgb2ycbcr( inputImage );
                        
            assert( numberOfChannels == 3 );

            vectorizedInputImage           = reshape( inputImage, numberOfRows * numberOfColumns, 3);  
            rgbFeatureVector               = vectorizedInputImage( roiMask, : )';%Features.NormalizeFeatures( vectorizedInputImage( roiMask, : )', [0 255], 0 );
            
            vectorizedHSVImage             = reshape( hsvImage, numberOfRows * numberOfColumns, 3);  
            hsvFeatureVector               = vectorizedHSVImage( roiMask, : )';
              
            vectorizedYCBCRImage           = reshape( ycbcrImage, numberOfRows * numberOfColumns, 3);  
            ycbcrFeatureVector             = vectorizedYCBCRImage( roiMask, : )';

            colorFeatureVector = [ rgbFeatureVector; hsvFeatureVector; ycbcrFeatureVector ];
        end
   end
   
end%classdef
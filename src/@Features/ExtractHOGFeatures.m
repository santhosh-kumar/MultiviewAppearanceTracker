%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Features::ExtractHOGFeatures
%
%   Extracts HOG Feature
%
%   Input -- 
%       obj                                   -  Feature Object
%       inputImage                            -  Input Image
%       roiMask                               -  region of interest mask
%       shouldConcatenateWithExistingFeatures -  Should concatenate features or not
%
%   Output -- 
%       obj                                   - Feature Object
%
%   Author -- Santhoshkumar Sunderrajan
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = ExtractHOGFeatures(  obj,...
                                    inputImage,...
                                    roiMask,...
                                    shouldConcatenateWithExistingFeatures )

    assert(  strcmp( obj.m_featureType, 'HOG' ) ||   strcmp( obj.m_featureType, 'HOG_AND_COLOR' ) );

    assert( nargin >= 3 );
    assert( size( inputImage, 3 ) == 3 );
    assert( ~isempty(inputImage) );
    assert( ~isempty(roiMask) );
    
    inputImage = double( rgb2ycbcr( inputImage ) );

    [ numberOfRows, numberOfColumns, ~ ] = size( inputImage );

    spatialBinSize      = obj.m_featureOptions.spatialBinSize;
    orientationBinSize  = obj.m_featureOptions.orientations;
                

    % compute HOG
    H = hog( double(inputImage), spatialBinSize, orientationBinSize );

    no_channels = size( H, 3);

    sr = spatialBinSize+1; er = numberOfRows - mod( numberOfRows, spatialBinSize ) - spatialBinSize;
    sc = spatialBinSize+1; ec = numberOfColumns - mod(numberOfColumns, spatialBinSize) - spatialBinSize;

    for slice_iter = 1 : no_channels
        temp_hog =  padarray( imresize( H( :, :, slice_iter ), [er-sr+1 ec-sc+1] ), [spatialBinSize spatialBinSize] ,'replicate', 'pre');
        hog_full( :,:,slice_iter) =  padarray( temp_hog, [mod(numberOfRows, spatialBinSize)+spatialBinSize mod(numberOfColumns, spatialBinSize)+spatialBinSize] ,'replicate', 'post');       
    end
    hog_full(hog_full<0) = 0;

    H = zeros( size(hog_full,1), size(hog_full,2), size(hog_full,3)/4);
    chunk_size = no_channels / 4;
    for o=0:3,
        hog_avg=H+hog_full(:,:,(1:chunk_size)+o*chunk_size);
    end;
    hog_avg(hog_avg<0)=0;
    stack_features = reshape(hog_avg, numberOfRows*numberOfColumns, no_channels/4)';
    dense_hog = stack_features(:, roiMask );
    hogFeatureVector        = [ dense_hog ./ repmat( sum( dense_hog ), orientationBinSize, 1 ) ]; 
    
    featureVector           = hogFeatureVector;

    if strcmp( obj.m_featureType, 'HOG_AND_COLOR' )
        rgbColorFeatureVector = Features.GenerateRawColorFeatures( inputImage, roiMask );
        featureVector         = [ featureVector; rgbColorFeatureVector ];
    end
    
    % remove nan's
    featureVector(isnan(featureVector) == 1) = 0;

    if shouldConcatenateWithExistingFeatures
        obj.m_featureVector      = [ obj.m_featureVector featureVector ];
    else
        obj.m_featureVector      =  featureVector;
    end

    assert( ~isempty( obj.m_featureVector ) );
                                                            
end
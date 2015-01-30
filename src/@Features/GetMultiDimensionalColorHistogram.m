%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This function sets the parameters of the DKF based on the intial state   
%                                                                               
%   Input --   
%       @I               - Input color image ( can be a vectorized image)
%       @isVectorized   -  Is the image vectorized into RGB components
%       @numberOfBins    - Number of Bins
%       @imageROI        - Region of interest
%
%   Output --
%       @multiDimensionalColorHistogram - A [numberOfBins numberOfBins
%       numberOfBins] matrix containing the histogram
%
%   Author(s) -- Vignesh Jagadeesh ( vignesh@ece.ucsb.edu ),
%             Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%             
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function multiDimensionalColorHistogram ...
                    = GetMultiDimensionalColorHistogram( I,...
                                                        isVectorized,...
                                                        numberOfBins )
    try                                            
        assert( nargin >= 1 );
        [ sizeX sizeY sizeC ] = size(I);

        %set the default values
        if ( nargin ==1 )
            isVectorized = 0;
            numberOfBins = 1;
        elseif ( nargin == 2 )
            numberOfBins = 8;
        end


        if( ~isVectorized && sizeC ~= 3 )
            error('Input is not a color Image');
        end

        if( isempty( numberOfBins ) )
            numberOfBins = 8; %default number of bins
        end

        I = double(I);            

        if (~isVectorized)
            R = I(:, :, 1); 
            G = I(:, :, 2); 
            B = I(:, :, 3);
        else
            R = I(:, 1); 
            G = I(:, 2); 
            B = I(:, 3);
        end

        roiPixels   = [ R, G, B ];

        %binWidth is the bin width while numberOfBins is the number of bins
        binWidth    = 256 ./ numberOfBins;

        %binning pixels
        h           = double( ceil( roiPixels / binWidth ) );
        h(h==0)     = 1; %change zeros to 1

        multiDimensionalColorHistogram    = zeros( numberOfBins, numberOfBins, numberOfBins );

        for rowIter = 1:size(h,1)
            multiDimensionalColorHistogram( h(rowIter,1), h(rowIter,2), h(rowIter,3) ) =...
            multiDimensionalColorHistogram( h(rowIter,1), h(rowIter,2), h(rowIter,3) ) + 1;
        end

        %Normalize to convert to a pdf
        multiDimensionalColorHistogram = multiDimensionalColorHistogram ./ sum( multiDimensionalColorHistogram(:) );

        multiDimensionalColorHistogram = multiDimensionalColorHistogram(:);
    catch ex
        fprintf( ex.message );
    end
end
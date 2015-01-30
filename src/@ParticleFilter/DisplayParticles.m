%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Display Particles
%
%   Input -- 
%       @obj        - object of type Particle Filter
%       @imageFrame - image frame
%
%   Output -- 
%       void
%
%   Author -- Santhoshkumar Sunderrajan( santhoshkumar@umail.ucsb.edu )
%
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DisplayParticles( obj, imageFrame )
    try
        figure(45);
        imshow(imageFrame);
        
        objectRectangle = obj.m_objectRectangle;
        
        
        weightList = obj.GetWeightList( );
        
        [ ~, sortedIndex ] = sort( weightList, 1, 'descend' );
        
        hold on;
        for i = 1 : ParticleFilter.NUMBER_OF_PARTICLES_TO_DISPLAY
            
            xMin = obj.m_stateMatrix( sortedIndex(i), 1 ) - obj.m_stateMatrix( sortedIndex(i), 3 ) * objectRectangle(3)/2;
            yMin = obj.m_stateMatrix( sortedIndex(i), 2 ) - obj.m_stateMatrix( sortedIndex(i), 4 ) * objectRectangle(4)/2;
            
            xMax = obj.m_stateMatrix( sortedIndex(i), 1 ) + obj.m_stateMatrix( sortedIndex(i), 3 ) * objectRectangle(3)/2;
            yMax = obj.m_stateMatrix( sortedIndex(i), 2 ) + obj.m_stateMatrix( sortedIndex(i), 4 ) * objectRectangle(4)/2;
            
            x_line = [ xMin xMin  xMax xMax xMin]; 
            y_line = [ yMin yMax  yMax yMin yMin]; 

            if i ~= 1
                colorCode = 'b';
                line( x_line, y_line, 'color', colorCode );
            else
                colorCode = 'g';
                line( x_line, y_line, 'color', colorCode );
            end
        end
        hold off;
    catch ex
        error( ['Failed to display particles:' ex] );
    end
end
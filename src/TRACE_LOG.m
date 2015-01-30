%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Logs info
%
%   Author -- Santhoshkumar Sunderrajan
%   Website -- http://www.uweb.ucsb.edu/~santhoshkumar/  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TRACE_LOG( message )
    global FID %#ok<TLEV>
    
    % log to file
    fprintf( FID, '%s\n', message );
    
    % log to console
    fprintf( '%s\n', message );

end


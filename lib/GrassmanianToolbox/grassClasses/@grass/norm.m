function n = norm(g, tanVec)
% NORM  -  Compute norm of a tangent vector for a grass object.
%
% Examples, g grass object, prop is one of tan, rtan, tan2 and rtan2.
%   n = norm(g,'tan')
%   n = norm(g,'rtan')
% 
% Copyright 2008.
% Berkant Savas, Linköping University.


%% tanVec is one of the following: tan, tan2, rtan, rtan2
switch tanVec
    % In the metric on Grassmann manifolds the norm is 
    % < tanVec , tanVec > = trace( tanVec' * tanVec )
    case 'tan'
        if ~isempty(g.tan)
            n = sum( sum( g.tan .* g.tan ) );    
        else
            error('tan is not defined.');
        end
    case 'rtan'
        if ~isempty(g.rtan)
            n = sum( sum( g.rtan .* g.rtan ) );    
        else
            error('rtan is not defined.');
        end
    case 'tan2'
        if ~isempty(g.tan2)
            n = sum( sum( g.tan2 .* g.tan2 ) );    
        else
            error('tan2 is not defined.');
        end
    case 'rtan2'
        if ~isempty(g.rtan2)
            n = sum( sum( g.rtan2 .* g.rtan2 ) );
        else
            error('rtan2 is not defined.');
        end
    otherwise
        error('Error: tanVec is not one of tan, tan2, rtan, rtan2');        
end
        
    
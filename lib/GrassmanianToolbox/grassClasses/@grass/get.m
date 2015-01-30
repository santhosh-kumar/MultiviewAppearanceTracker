function val = get(g, propName)
% GET  -  Get specified object properties.
% 
% Properties are: dim, data, base, proj, 
%                 tan, tan2, rtan, rtan2, 
%                 svd, rsvd
%
% Examples, g grass object
%   d = get(g, 'dim')
%   D = get(g, 'data')
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

switch propName
    case 'dim'
        val = g.dim;
    case 'data'
        val = g.data;
    case 'base'
        val = g.base;
    case 'proj'
        val = g.proj;
    case 'tan'        
        val = g.tan;
    case 'tan2'
        val = g.tan2;
    case 'rtan'
        val = g.rtan;
    case 'rtan2'
        val = g.rtan2;
    case 'svd'
        val = g.svd;
    case 'rsvd'
        val = g.rsvd;
    otherwise
        error([propName,' Is not a valid grass property'])
end
function val = innerProd(g)
% Inner product between tangent vectors g.tan and g.tan2 
% defined on the tangent space for the point g.data.
%
% Example: g grass object, both tangent vectors initiated.
%   val = innerProd(g)
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

val = sum( sum( g.tan .* g.tan2 ) );

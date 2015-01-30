function val = norm(G,tanVec)
% NORM  -  Compute norm of a tangent vector for a prodGrass object.
% 
% The norm for a prodGrass object is the sum of the norms of 
% its grass objects. 
% 
% Example: G prodGrass object, prop is one of tan, rtan, tan2 and rtan2.
%   n = norm(G,'tan')
%   n = norm(G,'rtan')
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

val = 0;
for i = 1:G.prodSize
    val = val + norm(G.grass{i},tanVec);
end
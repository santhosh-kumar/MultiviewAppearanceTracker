function G = move(G,t,prop)
% MOVE  -  parallel transport the data point and/or tangent vectos. 
%
% Examples, G pordGrass object, t is the step size, and prop is one of 
%           'p'     - move only the data point, 
%           'ptt'   - move the point and parallel transport both 
%                     tangent vectors, 
%           'pb'    - move the data point and update the basis.
%
%
%   G = move(G, t, 'p')
%   G = move(G, t, 'ptt')
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

for i = 1:G.prodSize
    G.grass{i} = move(G.grass{i},t,prop);
end

% after this step it may be good to clear the tangent 
% field and svd fields since they are not valid anymore....later
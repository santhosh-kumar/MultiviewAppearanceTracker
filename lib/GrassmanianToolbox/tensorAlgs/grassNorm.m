function f = grassNorm(g)
% Compute the norm of vectors on a product of Grassmann manifolds.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

f = 0;
if isa(g,'cell')
    for i = 1:size(g,2)
        f = f + norm(g{i},'fro');
    end
else
    f = norm(g,'fro');
end

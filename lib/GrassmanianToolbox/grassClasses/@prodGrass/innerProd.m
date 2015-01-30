function val = innerProd(G)
% Inner product between the first and second tangent vector in 
% global coordinates defined at the same point on a product 
% of Grassmann manifolds. D and D2 tangent points at X, 
% val = < D , D2 > =  trace( D{i}' * D2{i})
%
% Example: G prodGrass object and both D and D2 are set, 
% val = innerProd(G)
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

val = 0;
for i = 1:G.prodSize
    val = val + innerProd(G.grass{i});
end
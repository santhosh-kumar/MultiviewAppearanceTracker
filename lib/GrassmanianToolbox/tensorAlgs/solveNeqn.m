function [DX] = solveNeqn(g,H)
% Function for solving the Newton equations
% H x = - g 
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

[I(1),k(1)] = size(g{1});
[I(2),k(2)] = size(g{2});
[I(3),k(3)] = size(g{3});

g1 = reshape(g{1},I(1)*k(1),1);
g2 = reshape(g{2},I(2)*k(2),1);
g3 = reshape(g{3},I(3)*k(3),1);

g  = -[g1;g2;g3;];

[U,S,V] = svd(H);
r = rank(S);
x = V(:,1:r)*((U(:,1:r)'*g)./(diag(S(1:r,1:r))));

DX{1} = reshape(x(1:I(1)*k(1))    ,I(1),k(1));
DX{2} = reshape(x(I(1)*k(1)+1  :  I(1)*k(1)+I(2)*k(2)),I(2),k(2));
DX{3} = reshape(x(I(1)*k(1)+I(2)*k(2)+1:end),I(3),k(3));




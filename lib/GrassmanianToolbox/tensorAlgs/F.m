function f = F(A,G)
% Object function in the tensor approximation problem:
% -norm(A(X)); X is cell array with matrices.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

X = get(G,'data');
A = ttm(A,X,'t');
f=-(norm(A)^2)/2;

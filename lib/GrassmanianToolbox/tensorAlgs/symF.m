function f = symF(A,G)
% Object function in the symmetric tensor approximation problem:
% -norm(A(X)); X is cell array with same matrices.
% 
% Copyright 2009.
% Berkant Savas, Linköping University.

X = get(G,'data');
for i = 1:ndims(A)
    A = ttm(A,X,i,'t');
end
f=-(norm(A)^2)/2;




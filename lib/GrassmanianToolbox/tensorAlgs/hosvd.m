function [C,U,s]=hosvd(T)
% Compute the 'economi' version of the HOSVD of a tensor T.
% Call with [S,U,s] = hosvd(T)
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

T = tensor(T);
n = ndims(T);

for i = 1:n
    [U{i}, s{i},v] = svd(double(tenmat(T,i)),'econ');    
    s{i} = diag(s{i});
end

C = ttm(T,U,'t');
    


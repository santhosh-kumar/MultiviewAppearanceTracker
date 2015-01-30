function A = genTensor(varargin)
% Generate tensor: 
% Genrates random tensor with dimensions given in n,
% or tensor of rank(k) with noise amount rho.
% A = genTensor(n)  
% A = genTensor(n,k,rho)
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

%%
switch nargin 
    case 1
        n = varargin{1};
        A = tensor(randn(n'));
    case 3
        n = varargin{1};
        k = varargin{2};
        rho = varargin{3};
        A = tensor(randn(k'));
        X{1} = orth(randn(n(1),k(1)));
        X{2} = orth(randn(n(2),k(2)));
        X{3} = orth(randn(n(3),k(3)));
        A = ttm(A,X);
        A = A + tensor(rho*randn(n'));
    otherwise
        error('Input arrguments are not correct.')
end
function X = gmIniUnif(ns, par)
% Compute the assingment matrix by uniformly assigning the value of X.
%
% Remark
%   nn = n1 x n2
%
% Input
%   ns      -  #nodes, 1 x 2
%   par     -  parameter
%     nor   -  algorithm for normalization, {'none'} | 'unit' | 'doub'
%              'none' : no normalization on X
%              'unit' : unit normalization on vec(X)
%              'doub' : X has to be a doubly stochastic matrix
%
% Output
%   X       -  permutation matrix, n1 x n2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-25-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 02-17-2012

% function parameter
nor = ps(par, 'nor', 'none');

X = ones(ns) + eps;

if strcmp(nor, 'none')
    
elseif strcmp(nor, 'unit')
    X = X ./ norm(X(:));
    
elseif strcmp(nor, 'doub')
    X = bistocNormalize_slack(X, 1e-7);
    
else
    error('unknown algorithm: %s', non);
end

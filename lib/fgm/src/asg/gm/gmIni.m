function X = gmIni(K, ns, par)
% Initialize the assingment matrix.
%
% Remark
%   nn = n1 x n2
%
% Input
%   K       -  affinity matrix, nn x nn (sparse)
%   ns      -  #nodes, 1 x 2
%   par     -  parameter
%     alg   -  method, 'unif' | 'sm' | 'smac'
%                'unif' : uniform value
%                'sm'   : spectral matching (top eigen-vector of K)
%                'smac' : spectral matching with constraint
%
% Output
%   X       -  permutation matrix, n1 x n2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 10-15-2011
%   modify  -  Feng Zhou (zhfe99@gmail.com), 04-18-2012

% function parameter
alg = par.alg;

% uniform
if strcmp(alg, 'unif')
    X = gmIniUnif(ns, par);

% spectral matching    
elseif strcmp(alg, 'sm')
    X = gmIniSm(K, ns, par);
    
% spectral matching with affine constraint
elseif strcmp(alg, 'smac')
    X = gmIniSmac(K, ns, par);
    
else
    error('unknown initialization method: %s', alg);
end

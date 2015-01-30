function [G,stepVal,f,nn] = firstStepSD(A,G,k)
% Take a steepest descent direction as the 
% first step of an algorithm. 
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

% compute the gradient.
g = dF(A,G,'p');

% take a step along the steepest descent direction.
DX{1} = -g{1};
DX{2} = -g{2};
DX{3} = -g{3};

G = set(G,'tan',DX,'tan2',g);
stepVal = fminbnd(@(t) lineFunc(A,G,t,'gc'),0,1e-3);
%stepVal = 1e-7;
f = F(A,G);
nn = grassNorm(g);


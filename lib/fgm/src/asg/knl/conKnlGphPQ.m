function [KP, KQ] = conKnlGphPQ(gphs, parKnl)
% Compute node and feature affinity matrix for graph matching.
%
% Input
%   gphs    -  graphs, 1 x 2 (cell)
%   parKnl  -  parameter
%     alg   -  method of computing affinity, {'toy'} | 'cmum' | 'pas'
%              'toy':  toy data
%              'cmum': CMU motion data
%              'pas':  Pascal data
%
% Output
%   KP      -  node-node affinity, n1 x n2
%   KQ      -  edge-edge affinity, m1 x m2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 08-09-2011
%   modify  -  Feng Zhou (zhfe99@gmail.com), 05-12-2012

% function parameter
alg = ps(parKnl, 'alg', 'toy');

% dimension
gph1 = gphs{1};
gph2 = gphs{2};
[n1, m1] = size(gph1.G);
[n2, m2] = size(gph2.G);
m1 = m1 * 2;
m2 = m2 * 2;
prIn('conKnlGphPQ', 'alg %s, n1 %d, n2 %d, m1 %d, m2 %d', alg, n1, n2, m1, m2);

% for toy data
if strcmp(alg, 'toy')
    KP = zeros(n1, n2);
    DQ = conDst(gph1.XQ, gph2.XQ);
    KQ = exp(-DQ / .15);
    
% for cmu motion data
elseif strcmp(alg, 'cmum')
    KP = zeros(n1, n2);
    DQ = conDst(gph1.dsts, gph2.dsts);    
    KQ = exp(-DQ / 2500);
    
else
    error('unknown algorithm: %s', alg);
end

% normalize
% KQ = knlEgNor(KQ, parKnl);

% for symmetric edges
KQ = KQ(1 : round(m1 / 2), 1 : round(m2 / 2));

prOut;

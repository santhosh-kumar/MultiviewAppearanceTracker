function asg = gm(K, ns, asgT, parIni, parPosC, parPosD)
% Graph matching.
%
% This function can be used as the interface of the following algorithms:
%   Graudate Assignment, Spectral Matching, ...
%
% Math
%   This code is to solve the following problem:
%     max_X   vec(X)' * K * vec(X)
%     s.t.    X is a permutation matrix
%
% Remark
%   nn = n1 x n2
%
% Input
%   K        -  affinity matrix, nn x nn (sparse)
%   ns       -  #nodes, 1 x 2
%   asgT     -  ground-truth assignment (can be [])
%   parIni   -  parameter for initialization
%   parPosC  -  parameter for continuous-continuous post-processing
%   parPosD  -  parameter for continuous-discrete post-processing
%
% Output
%   asg      -  assignment
%     alg    -  algorithm name
%     X      -  binary correspondence matrix, n1 x n2
%     acc    -  accuracy (= 0 if asgT is [])
%     obj    -  objective value
%     tim    -  time cost
%
% History    
%   create   -  Feng Zhou (zhfe99@gmail.com), 01-25-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 04-23-2012

% function parameter
prIn('gm', 'ini %s, posC %s, posD %s', parIni.alg, parPosC.alg, parPosD.alg);
ha = tic;

% initialization
X0 = gmIni(K, ns, parIni);

% continous -> continous
XC = gmPosC(K, X0, parPosC);

% continous -> discrete
X = gmPosD(K, XC, parPosD);

% compare with ground-truth
acc = matchAsg(X, asgT);

% store
asg.alg = sprintf('gm+%s+%s+%s', parIni.alg, parPosC.alg, parPosD.alg);
asg.X = X;
asg.acc = acc;
asg.obj = X(:)' * K * X(:);
asg.tim = toc(ha);

prOut;

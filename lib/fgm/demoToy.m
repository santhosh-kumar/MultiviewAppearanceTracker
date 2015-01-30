% Test FGM on toy dataset.
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-20-2012
%   modify  -  Feng Zhou (zhfe99@gmail.com), 05-05-2012

clear variables;
prSet(3);

%% src
tag = 1; nIn = 15; nOuts = [0 0] + 0; egDen = .7; egDef = 0;
wsSrc = toyAsgSrc(tag, nIn, nOuts, egDen, egDef, 'svL', 1);
[gphs, asgT, ns] = stFld(wsSrc, 'gphs', 'asgT', 'ns');

%% affinity
parKnl = st('alg', 'toy');
[KP, KQ] = conKnlGphPQ(gphs, parKnl);
K = conKnlGphK(KP, KQ, gphs);

%% parameter
pars = gmPar(1);

%% SM
asgSm = gm(K, ns, asgT, pars{3}{:});

%% FGM
asgFgm = fgm(KP, KQ, gphs, asgT, pars{8}{1});

%% show correspondence matrix
asgs = {asgT, asgSm, asgFgm};
algs = {'Truth', 'SM', 'FGM'};
rows = 1; cols = 3;
Ax = iniAx(1, rows, cols, [250 * rows, 250 * cols]);
shAsgX(asgs, Ax, algs);

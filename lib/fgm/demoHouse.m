% Test FGM on CMU Motion (house) dataset.
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-20-2012
%   modify  -  Feng Zhou (zhfe99@gmail.com), 05-05-2012

clear variables;
prSet(5);

%% src
tag = 'house'; pFs = [1 100]; nIn = [30 30] - 2;
wsSrc = cmumAsgSrc(tag, pFs, nIn, 'svL', 1);
asgT = wsSrc.asgT;

%% feature
parG = st('link', 'del');
parF = st('smp', 'n', 'nBinT', 4, 'nBinR', 3);
wsFeat = cmumAsgFeat(wsSrc, parG, parF, 'svL', 1);
[gphs, Fs] = stFld(wsFeat, 'gphs', 'Fs');
ns = cellDim(wsSrc.Pts, 2);

%% affinity
parKnl = st('alg', 'cmum');
[KP, KQ] = conKnlGphPQ(gphs, parKnl);
K = conKnlGphK(KP, KQ, gphs);

%% parameter
pars = gmPar(1);

%% SM
asgSm = gm(K, ns, asgT, pars{3}{:});

%% FGM
asgFgm = fgm(KP, KQ, gphs, asgT, pars{8}{1});

%% show correpsondence matrix
asgs = {asgT, asgSm, asgFgm};
algs = {'Truth', 'SM', 'FGM'};
rows = 1; cols = 3;
Ax = iniAx(1, rows, cols, [250 * rows, 250 * cols]);
shAsgX(asgs, Ax, algs);

%% show correspondence result
rows = 2; cols = 1;
Ax = iniAx(2, rows, cols, [400 * rows, 900 * cols]);
parCor = st('mkSiz', 7, 'cls', {'y', 'b', 'g'});

shAsgImg(Fs, gphs, asgSm, asgT, parCor, 'ax', Ax{1});
title(sprintf('SM : acc %.2f, obj %.2f', asgSm.acc, asgSm.obj));
shAsgImg(Fs, gphs, asgFgm, asgT, parCor, 'ax', Ax{2});
title(sprintf('FGM: acc %.2f, obj %.2f', asgFgm.acc, asgFgm.obj));
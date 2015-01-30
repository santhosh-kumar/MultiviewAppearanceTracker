function wsSrc = toyAsgSrc(tag, nIn, nOuts, egDen, egDef, varargin)
% Generate toy source for assignment problem.
%
% Input
%   tag      -  shape type
%   nIn      -  #inlier nodes, 15 | ...
%   nOuts    -  #outlier nodes, 1 x 2, [0 0] | [10 20] | ...
%   egDen    -  density of edge connection, 0 ~ 1
%   egDef    -  deformation of edge feature, 0 ~ 1
%   varargin
%     save option
%
% Output
%   wsSrc
%     prex   -  prex
%     asgT   -  ground truth assignment
%     gphs   -  graph node set, 1 x mG (cell)
%     ns     -  #nodes, 1 x 2
%     mess   -  mean of Gaussian, 1 x mG (cell), 1 x ni (cell), d x 1
%     Varss  -  variance of Gaussian, 1 x mG (cell), 1 x ni (cell), d x d
%     ords   -  order, 1 x mG (cell), 1 x ni
%
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 08-11-2011
%   modify   -  Feng Zhou (zhfe99@gmail.com), 04-27-2012

% save option
prex = cellStr(tag, nIn, nOuts, egDef, egDen);
[svL, path] = psSv(varargin, 'prex', prex, ...
                             'subx', 'src', ...
                             'fold', 'toy/asg');

% load
if svL == 2 && exist(path, 'file')
    wsSrc = matFld(path, 'wsSrc');
    prInOut('toyAsgSrc', 'old, %s', prex);
    return;
end
prIn('toyAsgSrc', 'new, %s', prex);

% dimension
d = 2;
mG = 2;
ns = zeros(1, mG) + nIn + nOuts;

% inlier node
[meIns, VarIns] = toyGphMod(tag, nIn);
PtIn = toyGph(meIns, VarIns);

% distribution of nodes (not used for computing feature, only for visualization)
[ords, mess, Varss, Pts] = cellss(1, mG);
for iG = 1 : mG
    % outlier node
    [meOuts, VarOuts] = toyGphMod(1, nOuts(iG));
    PtOut = toyGph(meOuts, VarOuts);
    
    % combine nodes
    mes = cellCat(meIns, meOuts);
    Vars = cellCat(VarIns, VarOuts);
    Pt = [PtIn, PtOut];

    % randomly re-order
    ords{iG} = randperm(ns(iG));
    mess{iG} = mes(ords{iG});
    Varss{iG} = Vars(ords{iG});
    Pts{iG} = Pt(:, ords{iG});
end

% generate graph
parGph = st('link', 'rand', 'val', egDen);
gphs = newGphs(Pts, parGph);

% edge feature for inliers
ZIn = triu(rand(nIn), 1);
ZIn = ZIn + ZIn';

% feature for each graph
for iG = 1 : mG
    % edge feature for all nodes
    ni = ns(iG);
    Z = triu(rand(ni), 1);
    Z = Z + Z';

    % make sure the edge features for the inlier nodes are the same
    Z(1 : nIn, 1 : nIn) = ZIn;

    % add noise on the edge feature
    ZDef = egDef * triu(randn(ni), 1);
    ZDef = ZDef + ZDef';
    Z = Z + ZDef;

    % re-order the edge feature
    Z = Z(ords{iG}, ords{iG});

    % only keep the feature for existed edges because the graph is sparse
    [~, idx] = gphEg2Adj(gphs{iG}.Eg, ni);
    gphs{iG}.XQ = Z(idx);

    % node feature (not used in the experiment)
    gphs{iG}.XP = zeros(1, ni);
end

% ground-truth assignment
XT = zeros(ns);
idx = sub2ind(ns, 1 : nIn, 1 : nIn);
XT(idx) = 1;
asgT.alg = 'truth';
asgT.X = XT(ords{1}, ords{2});

% store
wsSrc.prex = prex;
wsSrc.mess = mess;
wsSrc.Varss = Varss;
wsSrc.ords = ords;
wsSrc.gphs = gphs;
wsSrc.asgT = asgT;
wsSrc.ns = ns;

% save
if svL > 0
    save(path, 'wsSrc');
end

prOut;

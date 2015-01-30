function gph = newGph(Pt, parGph)
% Generate a graph by connecting points.
%
% Input
%   Pt      -  graph node, d x n
%   parGph  -  parameter for computing the adjacency matrix
%              see gphEg.m for more details
%
% Output
%   gph     -  graph
%     Pt    -  graph node, d x n
%     Eg    -  graph edge, 2 x (2m)
%     vis   -  binary indicator of nodes that have been kept, 1 x n | []
%     G     -  node-edge adjacency, n x m
%     H     -  augumented node-edge adjacency, n x (m + n)
%     PtD   -  edge feature, 2 x m
%     dsts  -  distance, 1 x m
%     angs  -  angle, 1 x m
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 08-11-2011
%   modify  -  Feng Zhou (zhfe99@gmail.com), 04-26-2012

% dimension
n = size(Pt, 2);

% edge
[Eg, vis] = gphEg(Pt, parGph);

% incidence matrix
[G, H] = gphEg2Inc(Eg, n);

% second-order feature
[PtD, dsts, angs] = gphEg2Feat(Pt, Eg);

% store
gph.Pt = Pt;
gph.Eg = Eg;
gph.vis = vis;
gph.G = G;
gph.H = H;
gph.PtD = PtD;
gph.dsts = dsts;
gph.angs = angs;

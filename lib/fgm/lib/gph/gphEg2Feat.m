function [PtD, dsts, angs] = gphEg2Feat(Pt, Eg)
% Compute graph edge feature.
%
% Input
%   Pt      -  graph node, d x n
%   Eg      -  graph edge, 2 x (2m)
%
% Output
%   PtD     -  edge vector between pairwise nodes, d x (2m)
%   dsts    -  distance, 1 x (2m)
%   angs    -  angle, 1 x (2m)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 08-11-2011
%   modify  -  Feng Zhou (zhfe99@gmail.com), 04-26-2012

if isempty(Eg)
    PtD = [];
    dsts = [];
    angs = [];
    return;
end

% edge feature
Pt1 = Pt(:, Eg(1, :));
Pt2 = Pt(:, Eg(2, :));
PtD = Pt1 - Pt2;

% pair-wise distance
dsts = real(sqrt(sum(PtD .^ 2)));

% pair-wise angle
angs = atan(PtD(2, :) ./ (PtD(1, :) + eps));

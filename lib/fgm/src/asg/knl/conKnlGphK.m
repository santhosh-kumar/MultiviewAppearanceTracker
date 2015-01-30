function K = conKnlGphK(KP, KQ, gphs)
% Compute the global affinity matrix for graph matching.
%
% Remark
%   nn = n1 x n2
%
% Input
%   KP      -  node-node affinity, n1 x n2
%   KQ      -  edge-edge affinity, m1 x m2
%   gphs    -  graphs, 1 x 2 (cell)
%
% Output
%   K       -  affinity, nn x nn (sparse)
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 08-09-2011
%   modify  -  Feng Zhou (zhfe99@gmail.com), 04-26-2012

KQ = [KQ, KQ; KQ, KQ];

% dimension
[n1, n2] = size(KP);
[m1, m2] = size(KQ);
nn = n1 * n2;
prIn('conKnlGphK', 'nn %d', nn);

% edge
Eg1 = gphs{1}.Eg;
Eg2 = gphs{2}.Eg;

% global kernel
K = knlPQ2K(KP, KQ, Eg1, Eg2, n1, n2, m1, m2, nn);

prOut;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function K = knlPQ2K(KP, KQ, Eg1, Eg2, n1, n2, m1, m2, nn)
% Create a sparse affinity matrix from KP and KQ.

% edge affinity
I11 = repmat(Eg1(1, :)', 1, m2);
I12 = repmat(Eg1(2, :)', 1, m2);
I21 = repmat(Eg2(1, :), m1, 1);
I22 = repmat(Eg2(2, :), m1, 1);
I1 = sub2ind([n1 n2], I11(:), I21(:));
I2 = sub2ind([n1 n2], I12(:), I22(:));
idx1 = I1(:);
idx2 = I2(:);
vals = KQ(:);

% node affinity (put on the diagonal)
idx1 = [idx1; (1 : nn)'];
idx2 = [idx2; (1 : nn)'];
vals = [vals; KP(:)];

% create the sparse matrix
K = sparse(idx1, idx2, vals, nn, nn);

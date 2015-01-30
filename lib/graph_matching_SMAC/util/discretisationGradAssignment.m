function Xd=discretisationGradAssignment(X,E12,W,target);
% Timothee Cour, 21-Apr-2008 17:31:23
% This software is made publicly for research use only.
% It may be modified and redistributed under the terms of the GNU General Public License.

if nargin<4
    target=[];
end
[n1,n2]=size(E12);

% b0: sensitive parameter to tweak
% coeff=1;
coeff=1;
b0=coeff*max(n1,n2);

% bMax=1e3;
bMax=200;

tolB=1e-2;%1e-3;
% tolC=1e-3;%1e-3;
tolC=1e-3;%1e-3;

[X2,nbMatVec] = gradAssign(W, E12, b0, 1.075,bMax,tolB, tolC, target,X);


is_perfect_matching=1;

if is_perfect_matching
    Xd=discretisationMatching_hungarian(X2,E12);
else
    Xd=computeDiscreteCorrespondancesGreedy(X2,E12);
end

[Xd,scores]=compute_ICM_graph_matching(Xd,E12,W);


function [W,D1,D2]=normalizeMatchingW(W,E12,normalization,nbIter);
% W: must be tril (use W=tril(W))
% E12: n1*n2 correspondance matrix.
% assumes that [I12(:,1),I12(:,2)] = find(E12); will be such that: the
% kth dimensions in W corresponds to the match (I12(k,1),I12(k,2)) 
% normalization, nbIter: optional parameters
% Timothee Cour, 21-Apr-2008 17:31:23
% This software is made publicly for research use only.
% It may be modified and redistributed under the terms of the GNU General Public License.


if nargin<3
%     normalization='D1D2';
    normalization='iterative';
end
if nargin<4
    nbIter=10;
end

options.normalization=normalization;
if strcmp(normalization,'iterative')
    options.nbIter=nbIter;
end

E12=full(E12);
[I12(:,1),I12(:,2)] = find(E12);

[n1,n2]=size(E12);
options.n1n2=[n1,n2];

if nargout==1
    [W] = mex_normalizeMatchingW(W,I12,options);
elseif nargout==2
    [W,D1] = mex_normalizeMatchingW(W,I12,options);
else
    [W,D1,D2] = mex_normalizeMatchingW(W,I12,options);
end
% [W,D1,D2] = mex_normalizeMatchingW(W,I12,options);


W=W/max(max(W));

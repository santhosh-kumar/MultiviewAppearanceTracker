function [X,lambda,timing,constraintViolation] = compute_matching_from_W(W,E12,k,constraintMode,isAffine,isNcut);
% Timothee Cour, 21-Apr-2008 17:31:23
% This software is made publicly for research use only.
% It may be modified and redistributed under the terms of the GNU General Public License.

constraintViolation=[];
% usage:
% E12 = matching hypothesis (E12=ones(n1,n2) if full-matching)
% k = # eigenvectors
% constraintMode = 'none' | 'col' | 'row' | 'both'
% isAffine = 0 | 1
% [X,lambda] = compute_matching_from_W(W,ones(n1,n2),5,'row',1,0);

[n1,n2] = size(E12);
n12 = length(W);
% W=tril(W);

if nargin<6
    isNcut=0;
end
if nargin<5
    isAffine=1;
end

time_eigensolverTotal = cputime;
if strcmp(constraintMode,'none')
    [X0,lambda,timing] = computeKFirstEigenvectors(W,k,isNcut);
else
    [C,b] = computeConstraintMatching(E12,constraintMode);
    if strcmp(constraintMode,'both')
        C = C(1:end-1,:);%otherwise overconstrained !!
        b = b(1:end-1);
    end
        
    if isAffine
        [X0,lambda,timing,constraintViolation] = computeEigenvectorsAffineConstraint(W,C,b,k,isNcut);
    else
        [X0,lambda,timing] = computeNcutConstraint_projection(W,C,k,isNcut);
    end
end
time_eigensolverTotal = cputime-time_eigensolverTotal;
timing.eigensolverTotal=time_eigensolverTotal;

% disp(lambda);
X = zeros(n1*n2,k);
X(E12>0,:) = X0;
X=reshape(X,n1,n2,k);




%{
function [X,lambda,timing] = computeNcutConstraint_bias_term(W,C,b,k,isNcut);
regularization=-1;W=W+regularization*speye(length(W));

n=length(W);
% W=[1,sparse(1,n);sparse(n,1),W];

L=0.5*ones(n,1);
W=[1,L';L,W];
W=tril(W);
nc=size(C,1);
C=[sparse(nc,1),C;1,sparse(1,n)];
b=[1;b];
[X,lambda,timing] = computeEigenvectorsAffineConstraint(W,C,b,k,isNcut);

X=X(2:end,:);
%}


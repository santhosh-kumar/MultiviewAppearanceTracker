function [X12,X_SMAC,timing]=compute_graph_matching_SMAC(W,E12,options);
%{
% Timothee Cour, 21-Apr-2008 17:31:23 + update febrary 2009
% This software is made publicly for research use only.
% It may be modified and redistributed under the terms of the GNU General Public License.

Code implementing graph matching algorith in paper:
Balanced Graph Matching. Timothee Cour, Praveen Srinivasan, Jianbo Shi.
Advances in Neural Information Processing Systems (NIPS), 2006

spectral graph matching with affine constraint (SMAC)
optionally does kronecker bistochastic normalization of W

input:
E12: n1 x n2 binary matrix indicating feasible matches between 2 graphs of size n1,n2
in this code, we require n1=n2 for the final discretization
E12(i1,i2)=1 iff (i1,i2) is a potential match
E12 is all ones for full-matching
[I12(:,1),I12(:,2)]=find(E12); indicates the potential matches

W: n12 x n12 (sparse) matrix, where n12=nnz(E12)
W12(ei,ej) is affinity between the ei_th match and the ej_th match:
ei=i1i2 and ej=j1j2
where i1=I12(ei,1),i2=I12(ei,2), j1=I12(ej,1),j2=I12(ej,2)


output:
X12: binary matrix of size n1xn2 indicating final matches (permutation matrix)

%}

%%set default options
optionsDefault.constraintMode='both'; %'both' for 1-1 graph matching
optionsDefault.isAffine=1;% affine constraint
optionsDefault.isOrth=1;%orthonormalization before discretization
optionsDefault.normalization='iterative';%bistochastic kronecker normalization
optionsDefault.discretisation=@discretisationGradAssignment; %function for discretization
optionsDefault.is_discretisation_on_original_W=0;
%discretisationGradAssignment | computeDiscreteCorrespondancesGreedy |
%discretisationMatching_max| discretisationMatching_max_2

if nargin<3
    options=[];
end
options=getOptions(optionsDefault,options);

assert(size(W,1)==nnz(E12));

W=tril(sparse(W));%for memory efficiency

%% kronecker normalization
if ~strcmp(options.normalization,'none')
    W2=normalizeMatchingW(W,E12,options.normalization);
else
    W2=W;
end

%% compute top eigenvectors under affine constraint (matching constraint)
k=3;
[X,lambda,timing,constraintViolation] = compute_matching_from_W(W2,E12,k,options.constraintMode,options.isAffine);


if 1
    %% orthonormalize X (X gets closer to a permutation: both bistochastic and orthonormal, see paper)
    X_SMAC=X(:,:,1);
    if options.isOrth
        X_SMAC=computeXorthonormal(X_SMAC);
    end
    X_SMAC(E12==0)=0;

    %% discretize X_SMAC
    % in terms of objective value (wrt W, not W2), it works better with unnormalized W for discretisation instead of W2
    % in terms of accuracy, W2 works better

    if options.is_discretisation_on_original_W
        X12=options.discretisation(X_SMAC,E12,W);
    else
        X12=options.discretisation(X_SMAC,E12,W2);
    end
    
else

    [X12,X_SMAC]=select_best_eigenvector(X,E12,W2,options);
end

0;

function [X12,X_SMAC]=select_best_eigenvector(X,E12,W,options);
X=cat(3,X,-X);
if options.isOrth
    X=computeXorthonormal(X);
end
[n1,n2,k]=size(X);
for i=1:k
    results(i).X=X(:,:,i);
    results(i).X12=options.discretisation(X(:,:,i),E12,W);
    results(i).score=computeObjectiveValue(W,results(i).X12);
end
[ignore,ind]=max([results.score]);
disp2('ind');
X12=results(ind).X12;
X_SMAC=results(ind).X;




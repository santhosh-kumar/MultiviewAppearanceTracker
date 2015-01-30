function [ Xhat ] = pcaReconstruct( Yk, X, U, mu, k )

% sizes / dimensions
siz = size(X);  nd = ndims(X);  [D,r] = size(U);
if(D==prod(siz) && ~(nd==2 && siz(2)==1)); siz=[siz, 1]; nd=nd+1; end
n = siz(end);

% subtract mean, then flatten X
Xorig = X;
muRep = repmat(mu, [ones(1,nd-1), n ] );
X = X - muRep;
X = reshape( X, D, n );

% Find Yk, the first k coefficients of X in the new basis
if( r<=k ); Uk=U; else Uk=U(:,1:k); end;

Xhat = Uk * Yk';
Xhat = reshape( Xhat, siz );
Xhat = Xhat + muRep;

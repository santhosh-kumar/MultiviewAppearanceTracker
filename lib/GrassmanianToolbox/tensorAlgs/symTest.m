% Test differnt symmetric tensor approximation algorithms.
% 
% Copyright 2009.
% Berkant Savas, Linköping University.

clear 
% n     = dimension of tensor modes
% k     = rank of approximating tensor
% order = order of tensor, 3 or 4
% r     = true rank of the tensor
% rho   = noise level

% Initiate variables
n = 10;
k = 3;
order = 3;
%order = 4;
r = 9;
rho = 1e-5;

% Generate a symmetric tensor.
A = genSymTensor(n,order);
%A = genSymTensor(n,order,r,rho);

% Initiate algorithm variables:
tolQN  = 5e-13;
tolALS = tolQN;
initIt = 20;
maxItQN= 300;
maxItALS= 300;

% Compute initial approximation with HOSVD.
[U,S,V]= svd(double(tam(A,1)));
X = U(:,1:k);
%X = orth(randn(n,k));

% Testruns with the different algorithms.
% Initial ALS steps to get close to the minimum.
if order == 3
    [solInit, fInit, nnInit] = algALS(A,{X,X,X},[k,k,k],initIt,tolALS);
elseif order ==4
    [solInit, fInit, nnInit] = algALS(A,{X,X,X,X},[k,k,k,k],initIt,tolALS);
end

tic
[solQNlc,fQNlc,nnQNlc] = symalgQNlc(A,solInit{1},n,k,maxItQN,tolQN,'scldIdent');
t(1) = toc;
tic
[solQNlc2,fQNlc2,nnQNlc2] = symalgQNlc(A,solInit{1},n,k,maxItQN,tolQN,'exHess');
t(2) = toc;
tic
[solQNgc,fQNgc,nnQNgc] = symalgQNgc(A,solInit{1},n,k,maxItQN,tolQN,'scldIdent');
t(3) = toc;
tic
[solQNgc2,fQNgc2,nnQNgc2] = symalgQNlc(A,solInit{1},n,k,maxItQN,tolQN,'exHess');
t(4) = toc;

tic
X = solInit{1};
if order == 3
    [solALS,fALS,nnALS] = algALS(A,{X,X,X},[k,k,k],maxItALS,tolALS);
elseif order == 4
    [solALS,fALS,nnALS] = algALS(A,{X,X,X,X},[k,k,k,k],maxItALS,tolALS);
end
t(5) = toc;

clf
semilogy(nnQNlc./abs(fQNlc),'r*-','markerSize',10)
hold on
semilogy(nnQNlc2./abs(fQNlc2),'r*-','markerSize',10)
semilogy(nnQNgc./abs(fQNgc),'b--.','markerSize',10)
semilogy(nnQNgc2./abs(fQNgc2),'b--.','markerSize',10)
semilogy(nnALS./abs(fALS),'k.-','markerSize',10)
grid on

ylabel('RELATIVE NORM OF THE GRADIENT' )
legend('BFGS: lc, I', 'BFGS: lc H','BFGS: gc I', 'BFGS: gc H', 'ALS')
xlabel('ITERATION #')
%xlim([0 100])
ylim([1e-16 1e-2])

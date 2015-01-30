% Test differnt tensor approximation algorithms.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

clear

%% Initiate variables:
% constants for the algorithms
tolQN  = 5e-13;
tolN   = tolQN;
tolCG  = 1e-8;
tolLQN = tolQN;
tolALS = tolQN;
initIt = 20; 
maxItQN= 300;
maxItN = 10;
maxItCG= 250;
maxItLQN= 200;
maxItALS= 300;
rho = 1e-1;  %this is the noise added to the generated tensor.

% tensor dimensions
%n = [7 10 10]';
%k = [3 4 5 ]';

% Only algQNgc and algQNlc with 'scldIdent' work on tensors with order 
% higher than three.
n = [5 5 5 5 5 5 5 5]';
k = [2 2 2 2 2 2 2 2]';

% use m vectors in L-BFGS
m = 5;

%% Generate the tensor.
A  = genTensor(n);


%% Compute initial approximation with HOSVD. 
[C,U,s] = hosvd(A);
for i = 1:ndims(A)
    X{i} = U{i}(:,1:k(i));    
%    X{i} = orth(randn(n(i),k(i)));
%    Y{i} = U{i}(:,k(i)+1:end);
end

%% Testruns with the different algorithms.

% Initial ALS steps to get close to the minimum.
[solInit, fInit, nnInit] = algALS(A,X,k,initIt,tolALS);
tic
[solQNgc,fQNgc,nnQNgc] = algQNgc(A,solInit,n,k,maxItQN,tolQN,'scldIdent');
%[solQNgc,fQNgc,nnQNgc] = algQNgc(A,solInit,n,k,maxItQN,tolQN,'exHess');
t(1) = toc;

tic
%[solQNlc,fQNlc,nnQNlc] = algQNlc(A,solInit,n,k,maxItQN,tolQN,'scldIdent');
%[solQNlc,fQNlc,nnQNlc] = algQNlc(A,solInit,n,k,maxItQN,tolQN,'exHess');
t(2) = toc;

tic
%[solNgc,fNgc,nnNgc] = algNgc(A,solInit,n,k,maxItN,tolN);
t(3)= toc;

tic
%[solNlc,fNlc,nnNlc] = algNlc(A,solInit,n,k,maxItN,tolN);
t(3)= toc;

tic
%[solLQN, fLQN, nnLQN] = algLBFGS(A,solInit,n,k,maxItLQN,tolLQN,m);
t(4) = toc;

tic
[solALS,fALS,nnALS]   = algALS(A,solInit,k,maxItALS,tolALS);
t(5) = toc;
t'

% fQNgc = [fInit; fQNgc;]; fQNlc = [fInit; fQNlc;];
% fNgc  = [fInit; fNgc;]; fNlc  = [fInit; fNlc;];
% fALS  = [fInit; fALS;]; fLQN  = [fInit; fLQN;];
% 
% nnQNgc = [nnInit; nnQNgc;]; nnQNlc = [nnInit; nnQNlc;];
% nnNgc  = [nnInit; nnNgc;]; nnNlc  = [nnInit; nnNlc;];
% nnALS  = [nnInit; nnALS;]; nnLQN  = [nnInit; nnLQN;];

%%  Plot convergence
clf 
semilogy(nnQNgc./abs(fQNgc),'k--','lineWidth',2)
hold on
%semilogy(nnQNlc./abs(fQNlc),'r*-','markerSize',10)
%semilogy(nnNgc./abs(fNgc),'b*-','markerSize',8)
%semilogy(nnNlc./abs(fNlc),'ro-','markerSize',8)
%semilogy(nnLQN./abs(fLQN),'g.-','markerSize',10)
semilogy(nnALS./abs(fALS),'k-','lineWidth',2)
grid on
    
ylabel('RELATIVE NORM OF THE GRADIENT' )
%
legend('BFGS: I','HOOI')

%legend('QN - gc','QN - lc','N - gc','N - lc','L-QN','ALS')
xlabel('ITERATION #')
xlim([0 100])
ylim([1e-14 1e-0])


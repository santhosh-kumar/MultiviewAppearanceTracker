function [X,f,nn] = algNlc(A,X,n,k,maxIt,tol)
% Newton-Grassmann alg with reduced coordinate representation.
% function [X,f,nn] = algRedNewton(A,X,n,k,maxIt,tol)
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

%% Initiate and set the data for the prodGrass objekt. 
G = prodGrass(n,k);
G = set(G,'data',X,'base',X);

%% Reduced coordinate Newton-Grassmann alg.
it = 1;
done = 0;
tic
while ~done && it < maxIt
    [g,H] = compDeriv(A,G,n,k,'lc');
    DX    = solveNeqn(g,H);
    nn(it,1) = grassNorm(g);
    
    f(it,1) = F(A,G);    
    G = set(G,'rtan',DX);    
    stepVal(it) = fminbnd(@(t) lineFunc(A,G,t,'lc'),0,1);
    if nn(it)/abs(f(it)) < 1e-4
        stepVal(it) = 1;
    end    
    G = move(G,1,'pb'); 
    if nn(it)/abs(f(it)) < tol
      done   = 1;
    end
    disp([' Iteration: ', int2str(it)])
    it = it + 1;
end
toc
disp('----------Newton done (local coordinates)  ---------')
f = -f;
X = get(G,'data');

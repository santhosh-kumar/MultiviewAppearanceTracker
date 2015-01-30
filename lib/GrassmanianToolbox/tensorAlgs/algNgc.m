function [X,f,nn] = algNgc(A,X,n,k,maxIt,tol)
% Newton-Grassmann alg for best multilienear tensor approximation
% function [X,f,nn] = algNewtonGrass(A,X,n,k,maxIt,tol)
% 
% Copyright 2008.
% Berkant Savas, Linköping University.



%% Initiate and set the data for the prodGrass objekt. 
G = prodGrass(n,k);
G = set(G,'data',X,'proj',X);

%% Newton-Grassmann alg.
it = 1;
done = 0;
tic
while ~done && it < maxIt
    [g,H] = compDeriv(A,G,n,k,'gc');
    DX    = solveNeqn(g,H);  % this step is not good!
    DX    = projectTan(G,DX);
    nn(it,1) = grassNorm(g);
    
    f(it,1) = F(A,G);  
    G = set(G,'tan',DX);
    stepVal(it) = fminbnd(@(t) lineFunc(A,G,t,'gc'),0,1);
    if nn(it)/abs(f(it)) < 1e-4
        stepVal(it) = 1;
    end
    G = move(G,stepVal(it),'p');
    G = set(G,'proj',get(G,'data'));
    if abs(nn(it)/f(it)) < tol
        done  = 1;
    end
    disp([' Iteration: ', int2str(it)])
    it = it + 1;
end
toc
disp('----------Newton done (global coordinates)---------')
f = -f;
X = get(G,'data');
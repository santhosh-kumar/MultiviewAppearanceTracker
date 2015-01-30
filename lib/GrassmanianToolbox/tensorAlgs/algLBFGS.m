function [X,f,nn] = algLBFGS(A,X,n,k,maxIt,tol,m)
%  Limited Memory BFGS algorithm for best multilinear rank
%  approximation of a tenser using updates of the approximation
%  of the invers of the Hessian. See representations of q-n matrices
%  and their use in ... by Byrd, Nocedal and Schnabel 1992.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

%% Initiate and set the data for the prodGrass objekt.
G = prodGrass(n,k);
G = set(G,'data',X,'proj',X);

% The iteration process starts:
%% First step is special, do a steepest descent step to
% get the first Sk and Yk.
it = 1;
[G,stepVal(it),f(it),nn(it)] = firstStepSD(A,G,k);
Gp = G;
G = move(G,stepVal(it),'ptt');
G = set(G,'proj',get(G,'data'));

disp([' Iteration: ', int2str(it), ' Rel. norm: ', ...
    num2str(nn(it)/abs(f(it)))]);
it = it + 1;
Yk = [];Sk = [];Rk = [];Dk = [];

%%
done = 0;
while ~done && it < maxIt
    g  = dF(A,G,'p');
    sk = compSk(G,stepVal(it-1),'lbfgs');
    yk = compYk(G,g,'lbfgs');
    
    % Now form the L-BFGS matrices.
    [Sk,Yk,Rk,Dk] = compLBFGSmat(Sk,Yk,Rk,Dk,...
        Gp,sk,yk,it-1,m,stepVal(it-1),n,k);

    % now perform the computation of the search direction.
    DX = solveLBFGS(Sk,Yk,Rk,Dk,g,n,k);
    DX = projectTan(G,DX);

    nn(it,1) = grassNorm(g);
    G = set(G,'tan',DX,'tan2',g);
    f(it,1) = F(A,G);
    Gp = G;

    stepVal(it) = fminbnd(@(t) lineFunc(A,G,t,'gc'),0,1);
    %if nn(it)/abs(f(it)) < 1e-5
    %  stepVal(it) = 1;
    %end
   
    G = move(G,stepVal(it),'ptt');
    G = set(G,'proj',get(G,'data'));   
    if nn(it)/abs(f(it)) < tol
        done   = 1;
    end
    disp([' Iteration: ', int2str(it), ' Rel. norm: ', ...
        num2str(nn(it)/abs(f(it)))])
    it = it + 1;
end
disp('-------------L-BFGS done (algLBFGS)------------------------')
f = -f;
X = get(G,'data');
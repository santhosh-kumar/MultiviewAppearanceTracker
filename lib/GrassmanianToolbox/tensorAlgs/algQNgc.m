function [X,f,nn] = algQNgc(A,X,n,k,maxIt,tol,strInitH)
%  Quasi-Newton algorithm for best multilinear rank
%  approximation of a 3-tenser using updates of the
%  invers of the Hessian.
%
% Copyright 2008.
% Berkant Savas, Linköping University.

%% Initiate and set the data for the prodGrass objekt.
G = prodGrass(n,k);
G = set(G,'data',X,'proj',X);

% The iteration process starts:
%% First step is special, in fact a Newton step
it = 1;
[G,H,stepVal(it),f(it),nn(it)] = firstStepQN(A,G,n,k,strInitH,'gc');
Gp = G;
G = move(G,stepVal(it),'ptt');
G = set(G,'proj',get(G,'data'));

disp([' Iteration: ', int2str(it), ' Rel. norm: ', ...
    num2str(nn(it)/abs(f(it)))]);
it = it + 1;

%% MAIN LOOP
done = 0;
while ~done && it < maxIt
    % compute the gradient of the objective function
    g = dF(A,G,'p');
    
    Sk = compSk(G,stepVal(it-1),'gc');
    Yk = compYk(G,g,'gc');
    
    H = parTranHessian(H,Gp,G,stepVal(it-1));
    H = bfgsUpdate(H,Yk,Sk);
    
    DX = solveQNeqn(g,H);
    DX = projectTan(G,DX);
    nn(it,1) = grassNorm(g);
    
    G = set(G,'tan',DX,'tan2',g);
    f(it,1) = F(A,G);
    Gp = G;
    
    % One should use line search satisfying the Wolfe or
    % Goldstein conditions.
    stepVal(it) = fminbnd(@(t) lineFunc(A,G,t,'gc'),0,1);
    if nn(it)/abs(f(it)) < 1e-6
        stepVal(it) = 1;
    end
    
    G = move(G,stepVal(it),'ptt');
    G = set(G,'proj',get(G,'data'));
    
    if nn(it)/abs(f(it)) < tol
        done   = 1;
    end
    disp([' Iteration: ', int2str(it), ' Rel. norm: ', ...
        num2str(nn(it)/abs(f(it)))])
    it = it + 1;
end
disp('-------------Quasi-Newton done (global coordinates)-----------')
f = -f;
X = get(G,'data');
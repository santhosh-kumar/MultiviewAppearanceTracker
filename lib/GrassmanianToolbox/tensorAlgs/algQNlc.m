function [X,f,nn] = algQNlc(A,X,n,k,maxIt,tol,strInitH)
%  Quasi-Newton algorithm for best multilinear rank
%  approximation of a tenser using updates of the
%  invers of the Hessian.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

%% Initiate and set the data for the prodGrass objekt.
G = prodGrass(n,k);
G = set(G,'data',X,'base',X);

% The iteration process starts:
%% First step is special, in fact a Newton step
it = 1;
[G,H,stepVal(it),f(it),nn(it)] = firstStepQN(A,G,n,k,strInitH,'lc');


G = move(G,stepVal(it),'pb');

disp([' Iteration: ', int2str(it), ' Rel. norm: ', ...
        num2str(nn(it)/abs(f(it)))]);
it = it + 1;

%% MAIN LOOP
done = 0;
while ~done && it < maxIt
    % compute the gradient of the objective function
    g = dF(A,G,'b');
    
    Sk = compSk(G,stepVal(it-1),'lc');
    Yk = compYk(G,g,'lc');

    % No need to parallel transport in local coord. 
    H = bfgsUpdate(H,Yk,Sk);
    
    DX = solveQNeqn(g,H);

    nn(it,1) = grassNorm(g);
    
    G = set(G,'rtan',DX,'rtan2',g);
    f(it,1) = F(A,G);
    
    
    % One should use line search satisfying the Wolfe or
    % Goldstein conditions. 
    stepVal(it) = fminbnd(@(t) lineFunc(A,G,t,'lc'),0,1);
    if nn(it)/abs(f(it)) < 1e-6
        stepVal(it) = 1;
    end

    G = move(G,stepVal(it),'pb');
    
    if nn(it)/abs(f(it)) < tol
        done   = 1;
    end
    disp([' Iteration: ', int2str(it), ' Rel. norm: ', ...
        num2str(nn(it)/abs(f(it)))])
    it = it + 1;
end
toc
disp('-------------Quasi-Newton done (local coordinates)-----------')
f = -f;
X = get(G,'data');
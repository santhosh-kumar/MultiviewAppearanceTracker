function [X,f,nn] = symalgQNgc(A,X,n,k,maxIt,tol,strInitH)
%  Quasi-Newton algorithm for best multilinear rank
%  approximation of a symmetric tenser using updates of the
%  invers of the Hessian. Global coordinate implementation.
%
% Copyright 2009.
% Berkant Savas, Linköping University.

%% Initiate and set the data for the prodGrass objekt.
G = grass([n,k]);
G = set(G,'data',X,'proj',X);

% The iteration process starts:
%% First step is special, in fact a Newton step
it = 1;
[G,H,stepVal(it),f(it),nn(it)] = symFirstStepQN(A,G,n,k,strInitH,'gc');
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
    g = symdF(A,G,'p');
    
    Sk = compSk(G,stepVal(it-1),'gc');
    Yk = compYk(G,g,'gc');
    
    H = parTranHessian(H,Gp,G,stepVal(it-1));
    
    ro = 1/(Yk(:)'*Sk(:));
    t1 = H*Yk(:);
    H = H - ro*t1*Sk(:)' - ro * Sk(:)*t1' + ...
        (ro^2*(Yk(:)'*t1) + ro)*Sk(:)*Sk(:)' ;
    
    DX = -reshape(H*g(:),n,k);
    nn(it,1) = grassNorm(g);
    
    G = set(G,'tan',DX,'tan2',g);
    f(it,1) = symF(A,G);
    Gp = G;
    
    % One should use line search satisfying the Wolfe or
    % Goldstein conditions.
    stepVal(it) = fminbnd(@(t) symLineFunc(A,G,t,'gc'),0,1);
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
disp('-------Symmetric Quasi-Newton done (global coordinates)---------')
f = -f;
X = get(G,'data');
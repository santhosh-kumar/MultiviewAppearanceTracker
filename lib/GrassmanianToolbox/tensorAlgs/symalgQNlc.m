function [X,f,nn] = symalgQNlc(A,X,n,k,maxIt,tol,strInitH)
%  Quasi-Newton algorithm for best multilinear rank
%  approximation of a symmetric tenser using updates of the
%  invers of the Hessian. Local coordinate implementation. 
% 
% Copyright 2009.
% Berkant Savas, Linköping University.

%% Initiate and set the data for the prodGrass objekt.
G = grass([n,k]);
G = set(G,'data',X,'base',X);

% The iteration process starts:
%% First step is special, in fact a Newton step
it = 1;
[G,H,stepVal(it),f(it),nn(it)] = symFirstStepQN(A,G,n,k,strInitH,'lc');
G = move(G,stepVal(it),'pb');

disp([' Iteration: ', int2str(it), ' Rel. norm: ', ...
        num2str(nn(it)/abs(f(it)))]);
it = it + 1;

%% MAIN LOOP
done = 0;
while ~done && it < maxIt
    % compute the gradient of the objective function
    g = symdF(A,G,'b');

    Sk = compSk(G,stepVal(it-1),'lc');  
    Yk = compYk(G,g,'lc');     

    % No need to parallel transport in local coord. 
    % Compute BFGS update!
    ro = 1/(Yk(:)'*Sk(:));
    t1 = H*Yk(:);
    H = H - ro*t1*Sk(:)' - ro * Sk(:)*t1' + ...
        (ro^2*(Yk(:)'*t1) + ro)*Sk(:)*Sk(:)' ;
    
    DX = -reshape(H*g(:),n-k,k);
    nn(it,1) = grassNorm(g);
    
    G = set(G,'rtan',DX,'rtan2',g);
    f(it,1) = symF(A,G);
       
    % One should use line search satisfying the Wolfe or
    % Goldstein conditions. 
    stepVal(it) = fminbnd(@(t) symLineFunc(A,G,t,'lc'),0,1);
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
disp('-------Symmetric Quasi-Newton done (local coordinates)---------')
f = -f;
X = get(G,'data');
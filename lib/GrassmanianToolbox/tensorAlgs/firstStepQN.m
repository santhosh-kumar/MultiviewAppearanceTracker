function [G,H,stepVal,f,nn] = firstStepQN(A,G,n,k,str1,str2)
% Implementing first step of the Quasi-Newton algorithm.
%
% Copyright 2008.
% Berkant Savas, Linköping University.

if strcmp(str2,'gc')
    switch str1
        case 'exHess'
            [g,H]   = compDeriv(A,G,n,k,str2);
            H = pinv(H);
        case 'scldIdent'    % scaled identity, see p200 in Nocedal & Wright
            g = dF(A,G,'p');
            g  = projectTan(G,g);
            DX = g;
            G = set(G,'tan',DX,'tan2',g);
            stepVal = 1e-8;
            G = move(G,stepVal,'ptt');
            G = set(G,'proj',get(G,'data'));
            
            g = dF(A,G,'p');
            Sk = compSk(G,stepVal,'gc');
            Yk = compYk(G,g,'gc');
            
            t1 = 0;
            t2 = 0;
            for i = 1:size(Yk,2)
                t1 = t1 + sum(sum(Sk{i}.*Yk{i}));
                t2 = t2 + sum(sum(Yk{i}.*Yk{i}));
            end
            P = get(G,'proj');
            H = [];
            for i = 1:size(Yk,2)
                H = blkdiag(H,kron(eye(k(i)),P{i}));
            end
            H = t1/t2*H;            
        otherwise
            error('Invalid string option for initial Hessian approximation');
    end
    DX = solveQNeqn(g,H);
    DX = projectTan(G,DX);          %
    g  = projectTan(G,g);           %
    nn = grassNorm(g);
    G = set(G,'tan',DX,'tan2',g);
    
    f = F(A,G);
    
    stepVal = fminbnd(@(t) lineFunc(A,G,t,str2),0,1);
    while f < F(A,move(G,stepVal,'p')) &&  stepVal > 1e-10
        stepVal = stepVal/2;
        disp('---------reducing the stepsize --------')
    end
elseif strcmp(str2,'lc')
    switch str1
        case 'exHess'
            [g,H]   = compDeriv(A,G,n,k,str2);
            H = pinv(H);
        case 'scldIdent'    % scaled identity, see p200 in Nocedal & Wright
            g = dF(A,G,'b');
            H = eye((n-k)'*k);
            DX = solveQNeqn(g,H);
            G = set(G,'rtan',DX,'rtan2',g);
            stepVal = 1e-8;
            G = move(G,stepVal,'pb');
            g = dF(A,G,'b');
            Sk = compSk(G,stepVal,'lc');
            Yk = compYk(G,g,'lc');
            
            t1 = 0;
            t2 = 0;
            for i = 1:size(Yk,2)
                t1 = t1 + sum(sum(Sk{i}.*Yk{i}));
                t2 = t2 + sum(sum(Yk{i}.*Yk{i}));
            end
            H = t1/t2*eye((n-k)'*k);
            
        otherwise
            error('Invalid string option for initial Hessian approximation');
    end
    DX = solveQNeqn(g,H);
    nn = grassNorm(g);
    G = set(G,'rtan',DX,'rtan2',g);
    
    f = F(A,G);
    stepVal = fminbnd(@(t) lineFunc(A,G,t,str2),0,1);
    while f < F(A,move(G,stepVal,'pb')) &&  stepVal > 1e-10
        stepVal = stepVal/2;
        disp('---------reducing the stepsize --------')
    end
    
end
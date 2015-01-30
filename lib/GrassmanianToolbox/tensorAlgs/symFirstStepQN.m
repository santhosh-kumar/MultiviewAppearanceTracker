function [G,H,stepVal,f,nn] = symFirstStepQN(A,G,n,k,str1,str2)
% Implementing first step of the Quasi-Newton algorithm.
%
% Copyright 2009.
% Berkant Savas, Linöping University.

if strcmp(str2,'gc')
    switch str1
        case 'exHess'
            g = symdF(A,G,'p');
            H = symddF(A,G,'p');
            H = pinv(H);
        case 'scldIdent'
            g = symdF(A,G,'p');
            DX = -g;            
            G = set(G,'tan',DX,'tan2',g);
            stepVal = 1e-8;
            G = move(G,stepVal,'ptt');
            G = set(G,'proj',get(G,'data'));
           
            g = symdF(A,G,'p');
            Sk = compSk(G,stepVal,'gc');    
            Yk = compYk(G,g,'gc');    

            t1= sum(sum(Sk.*Yk));
            t2= sum(sum(Yk.*Yk));
            P = get(G,'proj');
            H = abs(t1)/t2*kron(eye(k),P);        
        otherwise
            error('Invalid string option for initial Hessian approximation.');
    end
    DX = -H*g(:);
    DX = reshape(DX,n,k);
    nn = grassNorm(g);
    G = set(G,'tan',DX,'tan2',g);

    f = symF(A,G);

    stepVal = fminbnd(@(t) symLineFunc(A,G,t,str2),0,1);
    while f < symF(A,move(G,stepVal,'p')) &&  stepVal > 1e-10
        stepVal = stepVal/2;
        disp('---------reducing the stepsize --------')
    end
elseif strcmp(str2,'lc')
    switch str1
        case 'exHess'
            g = symdF(A,G,'b');
            H = symddF(A,G,'b');
            H = pinv(H);
        case 'scldIdent'
            g = symdF(A,G,'b');
            DX = -g;
            G = set(G,'rtan',DX,'rtan2',g);
            stepVal = 1e-8;
            G = move(G,stepVal,'pb');
            g = symdF(A,G,'b');
            Sk = compSk(G,stepVal,'lc');
            Yk = compYk(G,g,'lc');

            t1= sum(sum(Sk.*Yk));
            t2= sum(sum(Yk.*Yk));
            H = t1/t2*eye((n-k)'*k);
        otherwise
            error('Invalid string option for initial Hessian approximation');
    end
    
    DX = -H*g(:);
    DX = reshape(DX,n-k,k);
    nn = grassNorm(g);
    G = set(G,'rtan',DX,'rtan2',g);

    f = symF(A,G);
    stepVal = fminbnd(@(t) symLineFunc(A,G,t,str2),0,1);
    while f < symF(A,move(G,stepVal,'pb')) &&  stepVal > 1e-10
        stepVal = stepVal/2;
        disp('---------reducing the stepsize --------')
    end

end


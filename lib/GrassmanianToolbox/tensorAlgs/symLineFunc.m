function f = symLineFunc(A,G,t,str)
% This is the function that the line search alg
% calls to get an appropriate step for the
% Newton algorithm.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.


if strcmp(str,'gc')
    G = move(G,t,'p');
    f = symF(A,G);
elseif strcmp(str,'lc')
    G = move(G,t,'pb'); %% why 'pb'??
    f = symF(A,G);
end
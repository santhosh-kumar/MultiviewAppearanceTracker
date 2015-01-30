function g=symdF(A,G,str)
% The gradient of the objective function in the
% tensor app problem
%
% Copyright 2009.
% Berkant Savas, Linköping University.

nd = ndims(A);

if nd == 3
    switch str
        case 'p'
            X = get(G,'data');
            P = get(G,'proj');
            F = ttm(A,{X,X},[2,3],'t');
            g = 3*ttt( ttm(F,P,1,'t'), ttm(F,X,1,'t'),[2:3],[2:3]);
            
        case 'b'
            X = get(G,'data');
            B = get(G,'base');
            F = ttm(A,{X,X},[2,3],'t');
            g = 3*ttt( ttm(F,B,1,'t'), ttm(F,X,1,'t'),[2:3],[2:3]);
    end
elseif nd > 3
    switch str
        case 'p'
            X = get(G,'data');
            P = get(G,'proj');
            F = ttm(A,X,2,'t');
            for i = 3:nd
                F = ttm(F,X,i,'t');
            end
            g = nd*ttt( ttm(F,P,1,'t'), ttm(F,X,1,'t'),[2:nd],[2:nd]);
        case 'b'
            X = get(G,'data');
            B = get(G,'base');
            F = ttm(A,X,2,'t');
            for i = 3:nd
                F = ttm(F,X,i,'t');
            end
            g = nd*ttt( ttm(F,B,1,'t'), ttm(F,X,1,'t'),[2:nd],[2:nd]);           
    end
end

g = -double(g);


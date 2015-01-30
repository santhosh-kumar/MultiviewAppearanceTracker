function g=dF(A,G,str)
% The gradient of the objective function in the
% tensor app problem
%
% Copyright 2008.
% Berkant Savas, Linköping University.

if ndims(A) == 3
    switch str
        case 'p'
            X = get(G,'data');
            P = get(G,'proj');
            
            T1 = ttm(A ,X{3},3,'t');
            T2 = ttm(T1,X{1},1,'t');
            T1 = ttm(T1,X{2},2,'t');
            T3 = ttm(A,{X{1},X{2}},[1,2],'t');
            F  = ttm(T2,X{2},2,'t');
            
            g{1} = -tam(T1,1)*tam(F,1)';
            g{2} = -tam(T2,2)*tam(F,2)';
            g{3} = -tam(T3,3)*tam(F,3)';
            
            g{1} = P{1}*g{1};
            g{2} = P{2}*g{2};
            g{3} = P{3}*g{3};
        case 'b'
            X = get(G,'data');
            B = get(G,'base');
            
            T1 = ttm(A ,X{3},3,'t');
            T2 = ttm(T1,X{1},1,'t');
            T1 = ttm(T1,X{2},2,'t');
            T3 = ttm(A,{X{1},X{2}},[1,2],'t');
            F  = ttm(T2,X{2},2,'t');
            
            g{1} = -tam(T1,1)*tam(F,1)';
            g{2} = -tam(T2,2)*tam(F,2)';
            g{3} = -tam(T3,3)*tam(F,3)';
            
            g{1} = B{1}'*g{1};
            g{2} = B{2}'*g{2};
            g{3} = B{3}'*g{3};
        otherwise
            errer('Invalid string argument, allowed p or b')
    end
elseif ndims(A) > 3    
     switch str
        case 'p'
            X = get(G,'data');
            P = get(G,'proj');
            
            F  = ttm(A,X,'t');
            g = cell(1,ndims(A));
            for i = 1:ndims(A)
                g{i} = - tam(ttm(A,X,-i,'t'),i) *tam(F,i)';
                g{i} = P{i}*g{i};
            end                       
        case 'b'
            X = get(G,'data');
            B = get(G,'base');
            
            F  = ttm(A,X,'t');
            g = cell(1,ndims(A));
            for i = 1:ndims(A)
                g{i} = - tam(ttm(A,X,-i,'t'),i) *tam(F,i)';
                g{i} = B{i}'*g{i};
            end            
        otherwise
            errer('Invalid string argument, allowed p or b')
    end
end


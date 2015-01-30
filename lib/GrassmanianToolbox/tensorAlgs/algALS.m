function [X, f, nn] = algALS(A,X,k,maxIt,tol)
% Alternating Least Squares algorithm for tensor approximation.
% Retruns the end-points in X, the norm of the gradien
% and the values of the objektive function.
%
% Copyright 2008.
% Berkant Savas, Linköping University.

it = 1;
done = 0;
while ~done && it <= maxIt
    % Update the three matrices
    for i = 1:ndims(A)
        An = ttm(A, X, -i,'t');
        [Un,s,v] = svd(tam(An, i),'econ');
        X{i} = Un(:,1:k(i));
    end
    
    % Compute the function value and norm of the gradient.
    T = ttm(A,X,'t');
    f(it,1) = norm(T)^2/2;
    
    for i = 1:ndims(A)
        P{i} = eye(size(X{i},1)) - X{i}*X{i}';
    end
    if ndims(A) == 3
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
    else
        F  = ttm(A,X,'t');
        g = cell(1,ndims(A));
        for i = 1:ndims(A)
            g{i} = - tam(ttm(A,X,-i,'t'),i) *tam(F,i)';
            g{i} = P{i}*g{i};
        end
        
    end
    nn(it,1) = 0;
    for i = 1:ndims(A)
        nn(it,1) =nn(it,1) + norm(g{i},'fro');
    end
    if nn(it)/f(it) < tol
        done   = 1;
    end
    disp([' Iteration: ', int2str(it), ' Rel. norm: ', ...
        num2str(nn(it)/abs(f(it)))])
    it = it + 1;
end
disp('-------------------ALS done------------------------')


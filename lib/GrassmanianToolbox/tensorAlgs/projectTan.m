function D = projectTan(G,D)
% This function is to project the computed search 
% directions onto the tangent plane at the current 
% point.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.



X = get(G,'data');
if isa (X,'cell')
    k = size(X,2);
    for i = 1:k
        D{i} = D{i} - X{i}*X{i}'*D{i};
    end
else 
    D = D - X*X'*D;
end

function DX = solveQNeqn(g,H)
% Solve the QN equations using the invers of the 
% Hessian to get the next searh direction, 
% which is simply x = -H*g
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

I = zeros(size(g,2),1);
k = I;
for i = 1:size(g,2)
    [I(i),k(i)] = size(g{i});
end

g1 = [];
for i = 1:size(g,2)
    g1 = [g1;reshape(g{i},I(i)*k(i),1)];
end

x = -H*g1;
ind = 0;
DX = cell(1,size(g,2));
for i = 1:size(g,2)
    DX{i} = reshape(x(ind + 1: ind + I(i)*k(i)), I(i), k(i));
    ind = I(1:i)'*k(1:i);
end



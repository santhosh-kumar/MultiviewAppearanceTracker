
% generate a random graph
A = rand(5) <= 0.5;
A = triu(A,1) ;
A = A + A';

%create the graph laplacian
L = diag(sum(A))- A;


x=zeros(5,1);
tmp = randperm(5); 
pos = tmp(1:3); 
x(pos)=1;

y = L*x;

find(y>0)
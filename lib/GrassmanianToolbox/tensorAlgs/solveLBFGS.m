function DX = solveLBFGS(Sk,Yk,Rk,Dk,g,n,k)
% Function to compute the new search direction 
% in limited memory BFGS. The Hessian approximation 
% stored in factored form are input arguments. 
% 
% Copyright 2008.
% Berkant Savas, Linköping University.



gamma = (Sk(:,end)'*Yk(:,end))/(Yk(:,end)'*Yk(:,end));
grad = [g{1}(:); g{2}(:);g{3}(:);];
D = gamma*grad;
T = [Sk'; gamma*Yk';]*grad;
T = [Rk'\(Dk + gamma*Yk'*Yk)/Rk -eye(size(Rk,1))/(Rk');...
  -eye(size(Rk,1))/Rk   zeros(size(Rk)) ]*T;
D = D + [Sk gamma*Yk]*T;

DX{1} = -reshape(D(1:n(1)*k(1)),n(1),k(1));
D = D(n(1)*k(1)+1:end);
DX{2} = -reshape(D(1:n(2)*k(2)),n(2),k(2));
D = D(n(2)*k(2)+1:end);
DX{3} = -reshape(D,n(3),k(3));


function [Sk,Yk,Rk,Dk] = compLBFGSmat(Sk,Yk,Rk,Dk,G,sk,yk,it,m,stepVal,n,k);
% Update of the factored Hessian approximation in limited 
% memory BFGS method to the new point on the manifold. 
% 
% Copyright 2008.
% Berkant Savas, Linköping University.



%%
% compute the transport matrix, i.e. from previous iteration to 
% present one in order to update/parallel transport the vectors
% in Sk and Yk
Z = get(G,'svd');
X = get(G,'data');
% this is not the proper way to do this. T will require a lot of memory.
T1 = [X{1}*Z{1}.V Z{1}.U]*[-diag(sin(diag(Z{1}.S)*stepVal));...
   diag(cos(diag(Z{1}.S)*stepVal))]*Z{1}.U' + ...
   eye(size(Z{1}.U,1)) - Z{1}.U * Z{1}.U';
T2 = [X{2}*Z{2}.V Z{2}.U]*[-diag(sin(diag(Z{2}.S)*stepVal));...
   diag(cos(diag(Z{2}.S)*stepVal))]*Z{2}.U' + ...
   eye(size(Z{2}.U,1)) - Z{2}.U * Z{2}.U';
T3 = [X{3}*Z{3}.V Z{3}.U]*[-diag(sin(diag(Z{3}.S)*stepVal));...
   diag(cos(diag(Z{3}.S)*stepVal))]*Z{3}.U' + ...
   eye(size(Z{3}.U,1)) - Z{3}.U * Z{3}.U';

%%
% update/transport the old vectors from previous point to present point
% then we can just compute the scalara products.
% in order to skip forming T above multiply with Ti whithin a loop.
if it > 1
  Sk1 = Sk(1:n(1)*k(1),:);
  Sk2 = Sk(n(1)*k(1)+1:n(1:2)'*k(1:2),:);
  Sk3 = Sk(n(1:2)'*k(1:2) + 1:end,:);
  Yk1 = Yk(1:n(1)*k(1),:);
  Yk2 = Yk(n(1)*k(1)+1:n(1:2)'*k(1:2),:);
  Yk3 = Yk(n(1:2)'*k(1:2)+1:end,:);  
  for i = 1:k(1)
    Sk1(n(1)*(i-1)+1:n(1)*i,:) = T1*Sk1(n(1)*(i-1)+1:n(1)*i,:);
    Yk1(n(1)*(i-1)+1:n(1)*i,:) = T1*Yk1(n(1)*(i-1)+1:n(1)*i,:);
  end
  for i = 1:k(2)
    Sk2(n(2)*(i-1)+1:n(2)*i,:) = T2*Sk2(n(2)*(i-1)+1:n(2)*i,:);
    Yk2(n(2)*(i-1)+1:n(2)*i,:) = T2*Yk2(n(2)*(i-1)+1:n(2)*i,:);
  end
  for i = 1:k(3)
    Sk3(n(3)*(i-1)+1:n(3)*i,:) = T3*Sk3(n(3)*(i-1)+1:n(3)*i,:);
    Yk3(n(3)*(i-1)+1:n(3)*i,:) = T3*Yk3(n(3)*(i-1)+1:n(3)*i,:);
  end
  Sk = [Sk1;Sk2;Sk3;];
  Yk = [Yk1;Yk2;Yk3;];
%    Sk = T*Sk;
%    Yk = T*Yk;
end

%%
if it <= m % these are for the initial steps.
  Sk = [Sk sk];
  Yk = [Yk yk];
  Dk(it,it) = sk'*yk;
  Rk  = [ [Rk ; zeros(1,it-1);] Sk'*yk; ];
else  % if it > m then we delete one vector and add a new one.
  Sk = [ Sk(:,2:end) sk];
  Yk = [ Yk(:,2:end) yk];
  d = diag(Dk);
  Dk = diag([d(2:end);sk'*yk]);
  Rk = Rk(2:end,2:end);
  Rk  = [ [Rk ; zeros(1,m-1);] Sk'*yk; ];
end




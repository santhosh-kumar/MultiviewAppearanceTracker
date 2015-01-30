function H = parTranHessian(H,G1,G2,t)
% Parallel transport the Hessian from the previous
% point on the manifold to the current point on the manifold.
%
% Copyright 2008.
% Berkant Savas, Linköping University.


X1 = get(G1,'data');
X2 = get(G2,'data');
s1 = get(G1,'svd');
s2 = get(G2,'svd');

if iscell(X1)
    for i = 1:size(X1,2)
        T1{i} = [X1{i}*s1{i}.V s1{i}.U]*[-diag(sin(diag(s1{i}.S)*t)); ...
            diag(cos(diag(s1{i}.S)*t))]*s1{i}.U' + ...
            eye(size(s1{i}.U,1)) -  s1{i}.U*s1{i}.U';
        P1{i} = kron(eye(size(X1{i},2)),T1{i});
        T2{i} = [X2{i}*s2{i}.V s2{i}.U]*[-diag(sin(diag(s2{i}.S)*-t)); ...
            diag(cos(diag(s2{i}.S)*-t))]*s2{i}.U' + ...
            eye(size(s2{i}.U,1)) -  s2{i}.U*s2{i}.U';
        P2{i} = kron(eye(size(X1{i},2)),T2{i});
    end
    
    T1 = []; T2 = [];
    for i = 1:size(X1,2)
        T1 = blkdiag(T1,P1{i});
        T2 = blkdiag(T2,P2{i});
    end
else
    T1 = [X1*s1.V s1.U]*[-diag(sin(diag(s1.S)*t)); ...
        diag(cos(diag(s1.S)*t))]*s1.U' + ...
        eye(size(s1.U,1)) -  s1.U*s1.U';
    P1 = kron(eye(size(X1,2)),T1);
    T2 = [X2*s2.V s2.U]*[-diag(sin(diag(s2.S)*-t)); ...
        diag(cos(diag(s2.S)*-t))]*s2.U' + ...
        eye(size(s2.U,1)) -  s2.U*s2.U';
    P2 = kron(eye(size(X1,2)),T2);
    
    T1 = P1;
    T2 = P2;
end

H = T1*H*T2;

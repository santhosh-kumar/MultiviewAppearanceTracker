function [g,H] = compDeriv(A,G,n,k,str)
% Compute the gradient and Hessian of the objective 
% function more efficiently.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

if strcmp(str,'gc')
    X = get(G,'data');
    P = get(G,'proj');

    T1 = ttm(A, X{1},1,'t');
    T2 = ttm(T1,X{2},2,'t');
    T3 = ttm(T1,P{2},2);

    F  = ttm(T2,X{3},3,'t');
    Bz = ttm(T2,P{3},3);
    By = ttm(T3,X{3},3,'t');
    Cx = ttm(T3,P{3},3);

    T1 = ttm(A,P{1},1);
    T2 = ttm(T1,X{2},2,'t');
    T3 = ttm(T1,P{2},2);

    Bx = ttm(T2,X{3},3,'t');
    Cy = ttm(T2,P{3},3);
    Cz = ttm(T3,X{3},3,'t');

    g{1} = -double(ttt(Bx,F,[2,3]));
    g{2} = -double(ttt(By,F,[1,3]));
    g{3} = -double(ttt(Bz,F,[1,2]));

    Hxx = kron(eye(k(1)),double(ttt(Bx,Bx,[2,3]))) - ...
        kron(double(ttt(F,F,[2,3])),P{1});
    Hyy = kron(eye(k(2)),double(ttt(By,By,[1,3]))) - ...
        kron(double(ttt(F,F,[1,3])),P{2});
    Hzz = kron(eye(k(3)),double(ttt(Bz,Bz,[1,2]))) - ...
        kron(double(ttt(F,F,[1,2])),P{3});
    Hxy = double(tenmat(ttt(Cz,F,3),[1,3],[2,4]) + ...
        tenmat(ttt(Bx,By,3),[1,3],[4,2]));
    Hxz = double(tenmat(ttt(Cy,F,2),[1,3],[2,4]) + ...
        tenmat(ttt(Bx,Bz,2),[1,3],[4,2]));
    Hyz = double(tenmat(ttt(Cx,F,1),[1,3],[2,4]) + ...
        tenmat(ttt(By,Bz,1),[1,3],[4,2]));

    H = - vertcat(horzcat(Hxx ,Hxy ,Hxz),...
        horzcat(Hxy',Hyy ,Hyz),...
        horzcat(Hxz',Hyz',Hzz));
elseif strcmp(str,'lc')

    %% Initiate and compute the needed variables.
    X = get(G,'data');
    Y = get(G,'base');

    Bz  = ttm(A, X{1},1,'t');   %temporary
    By  = ttm(Bz,X{2},2,'t');   %temporary
    Cyz = ttm(Bz,Y{2},2,'t');   %temporary

    F   = ttm(By ,X{3},3,'t');    %final
    Bz  = ttm(By ,Y{3},3,'t');    %final
    By  = ttm(Cyz,X{3},3,'t');    %final
    Cyz = ttm(Cyz,Y{3},3,'t');    %final

    Bx  = ttm(A,Y{1} ,1,'t');   %temporary
    Cxz = ttm(Bx,X{2},2,'t');   %temporary
    Cxy = ttm(Bx,Y{2},2,'t');   %temporary

    Bx  = ttm(Cxz,X{3},3,'t');  %final
    Cxz = ttm(Cxz,Y{3},3,'t');  %final
    Cxy = ttm(Cxy,X{3},3,'t');  %final

    %% Compute the gradient
    g{1} = -double(ttt(Bx,F,[2,3]));
    g{2} = -double(ttt(By,F,[1,3]));
    g{3} = -double(ttt(Bz,F,[1,2]));

    %% Compute the Hessian
    Bxx = kron(eye(k(1)),double(ttt(Bx,Bx,[2,3]))) - ...
        kron(double(ttt(F,F,[2,3])),eye(n(1) - k(1)));
    Byy = kron(eye(k(2)),double(ttt(By,By,[1,3]))) - ...
        kron(double(ttt(F,F,[1,3])),eye(n(2) - k(2)));
    Bzz = kron(eye(k(3)),double(ttt(Bz,Bz,[1,2]))) - ...
        kron(double(ttt(F,F,[1,2])),eye(n(3) - k(3)));
    Bxy = double(tenmat(ttt(Cxy,F,3),[1,3],[2,4]) + ...
        tenmat(ttt(Bx,By,3),[1,3],[4,2]));
    Bxz = double(tenmat(ttt(Cxz,F,2),[1,3],[2,4]) + ...
        tenmat(ttt(Bx,Bz,2),[1,3],[4,2]));
    Byz = double(tenmat(ttt(Cyz,F,1),[1,3],[2,4]) + ...
        tenmat(ttt(By,Bz,1),[1,3],[4,2]));

    H = - vertcat(horzcat(Bxx ,Bxy ,Bxz),...
        horzcat(Bxy',Byy ,Byz),...
        horzcat(Bxz',Byz',Bzz));

end



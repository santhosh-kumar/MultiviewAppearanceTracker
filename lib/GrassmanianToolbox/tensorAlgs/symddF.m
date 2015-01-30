function H=symddF(A,G,str)
%--------------------------------------------------
%
% The Hessian of the object function in the
% tensor app problem
%
%--------------------------------------------------
X = get(G,'data');
[n k] = size(X);
if str == 'p'
    P = get(G,'proj');
elseif str == 'b'
    P = get(G,'base');
end

if ndims(A) == 3
    T1 = ttm(A,{X,X},[1,3],'t');
    T2 = ttm(A,{P,X},[1,3],'t');
    T3 = ttm(T2,X,2,'t');
    F  = ttm(T1,X,2,'t');

    H1 = 6*ttt( ttm(T2,P,2,'t'), F ,3 );
    H2 = 3*ttt( T3,T3,[2,3]);
    H3 = 6*ttt( T3, ttm(T1,P,2,'t'), 3);
    H4 = 3*ttt(F,F,[2,3]);
    
    H1 = double(tenmat(H1,[2,4],[1,3]));
    H2 = kron(eye(size(X,2)),double(H2));
    H3 = double(tenmat(H3,[4,2],[1,3]));
    if str == 'p'
        H4 = kron(double(H4),P);
    elseif str == 'b'
        H4 = kron(double(H4),eye(-diff(size(X))));
    end


    H = -(H1 + H2 + H3 - H4);

elseif ndims(A) == 4
    C12 = ttm(A,{X,X},[3,4],'t');
    F   = ttm(C12,X,2,'t');
    B1  = ttm(F,P,1,'t');
    F   = ttm(F,X,1,'t');

    B2  = ttm(C12,P,2,'t');
    C12 = ttm(B2,P,1,'t');
    B2  = ttm(B2,X,1,'t');

    H12 = 12*double(tenmat(ttt(C12,F,[3,4]),[1,3],[2,4]) + ...
        tenmat(ttt(B1,B2,[3,4]),[1,3],[4,2]));

    if str == 'p'
        H11 = 4*(kron(eye(k),double(ttt(B1,B1,[2,3,4]))) - ...
            kron(double(ttt(F,F,[2,3,4])),P));
    elseif str == 'b'
        H11 = 4*(kron(eye(k),double(ttt(B1,B1,[2,3,4]))) - ...
            kron(double(ttt(F,F,[2,3,4])),eye(n - k)));
    end


    H = -(H11 + H12);

end




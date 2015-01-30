function H = bfgsUpdate(H,Yk,Sk)
% BFGS update of the invers of the approximate Hessian. 
% 
% Copyright 2008.
% Berkant Savas, Linköping University.


yk = [];
sk = [];
for i = 1:size(Yk,2)
    yk = [yk; Yk{i}(:);];
    sk = [sk; Sk{i}(:);];
end

ro = 1/(yk'*sk);
t1 = H*yk;
H = H - ro*t1*sk' - ro * sk*t1' + ...
    (ro^2*(yk'*t1) + ro)*(sk*sk') ;


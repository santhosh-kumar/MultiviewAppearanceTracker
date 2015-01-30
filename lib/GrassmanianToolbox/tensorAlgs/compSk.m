function Sk = compSk(G,t,str)
% Computation of the Sk term in the BFGS update.
%
% Copyright 2008.
% Berkant Savas, Linköping University.

switch str
    case 'gc'
        T1 = get(G,'tan');
        if iscell(T1)
            for i = 1:size(T1,2)
                Sk{i} = T1{i}*t;
            end
        else
            Sk = T1*t;
        end
    case 'lc'
        T1 = get(G,'rtan');
        if iscell(T1)
            for i = 1:size(T1,2)
                Sk{i} = T1{i}*t;
            end
        else
            Sk = T1*t;
        end
    case 'lbfgs'
        T1 = get(G,'tan');
        for i = 1:size(T1,2)
            Sk{i} = T1{i}*t;
        end
        Sk = [Sk{1}(:); Sk{2}(:); Sk{3}(:);];
    otherwise
        disp('Invalid string argument')
end

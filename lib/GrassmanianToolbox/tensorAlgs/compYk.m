function Yk = compYk(G,g,str)
% Computation of the Yk term in the BFGS update.
%
% Copyright 2008.
% Berkant Savas, Linköping University.

switch str
    case 'gc'
        T2 = get(G,'tan2');
        if iscell(T2)
            for i = 1:size(T2,2)
                Yk{i} = g{i} - T2{i};
            end
        else
            Yk = g - T2;
        end
    case 'lc'
        T2 = get(G,'rtan2');
        if iscell(T2)
            for i = 1:size(T2,2)
                Yk{i} = g{i} - T2{i};
            end
        else
            Yk = g - T2;
        end
    case 'lbfgs'
        T2 = get(G,'tan2');
        Yk = [];
        for i = 1:size(T2,2)
            Yk = [Yk; g{i}(:) - T2{i}(:);];
        end
    otherwise
        disp('Invalid string argument')
end




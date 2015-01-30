function X = gmPosDHun(X0, varargin)
% Post-processing the continuous correspondence matrix
% to obtain a discrete solution by the Hungrian algorithm.
%
% Input
%   X0      -  continuous correspondence, n1 x n2
%   varargin
%     opt   -  optimization operator, 'min' | {'max'}
%
% Output
%   X       -  discrete correspondence, n1 x n2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-25-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 02-28-2012

% function option
opt = ps(varargin, 'opt', 'max');

if strcmp(opt, 'max')
    X0 = max(X0(:)) - X0;
elseif strcmp(opt, 'min')
    % do noting
else
    error('unknown operator: %s', opt);
end

% X0(E12 == 0) = Inf;

% c++ implementation
ind2 = assignmentoptimal(X0);

% dimension
[n1, n2] = size(X0);

% index -> matrix
if n1 <= n2
    idx = sub2ind([n1 n2], 1 : n1, ind2');
    
else
    ind1 = find(ind2);
    ind2 = ind2(ind1);
    idx = sub2ind([n1 n2], ind1', ind2');
end
X = zeros(n1, n2);
X(idx) = 1;

%X2 = hungarian(X0);
%equal('X', X, X2);

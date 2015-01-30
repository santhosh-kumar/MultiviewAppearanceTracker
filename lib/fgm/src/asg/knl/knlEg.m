function [KP, KQ] = knlEg(XPs, XQs, egAlg)
% Compute edge affinity.
%
% Input
%   XPs     -  node feature, 1 x 2 (cell), dP x ni
%   XQs     -  edge feature, 1 x 2 (cell), dQ x mi
%   egAlg   -  method of computing edge kernel, 'toy' | 'cmum' | ...
%
% Output
%   KP      -  
%   KQ      -  edge affinity, m1 x m2
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 08-09-2011
%   modify  -  Feng Zhou (zhfe99@gmail.com), 05-12-2012

% dimension
[dEg, m1] = size(XEgs{1});
m2 = size(XEgs{2}, 2);

if strcmp(egAlg, 'toy')
    DEg = conDst(XEgs{1}, XEgs{2});
    KEg = exp(-DEg / .15);
    
elseif strcmp(egAlg, 'cmum')
    DEg = conDst(XEgs{1}, XEgs{2});
    KEg = exp(-DEg / 2500);

else
    error('unknown algorithm: %s', egAlg);
end

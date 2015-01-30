function src = cmumSrc(tag)
% Obtain a CMU Motion source.
%
% Input
%   tag     -  src name, {'house'}
%
% Output
%   src
%     dbe   -  'cmum'
%     nm    -  src name
%     XTs   -  ground-truth marker, 1 x nF (cell), 2 x nPt
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 07-30-2011
%   modify  -  Feng Zhou (zhfe99@gmail.com), 10-09-2011

% src nm
prIn('cmumSrc', 'tag %s', tag);

% ground-truth label
CMUM = cmumHuman;

% marker
XTs = CMUM.(tag).XTs;

% store
src.dbe = 'cmum';
src.nm = tag;
src.XTs = XTs;

prOut;

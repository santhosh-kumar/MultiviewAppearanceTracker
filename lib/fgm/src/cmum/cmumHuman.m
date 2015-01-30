function CMUM = cmumHuman
% Load ground label file for CMU Motion sequence.
%
% Output
%   CMUM   -  a container
%     tag  -  sequence name
%       seg
%       cnames
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 12-29-2008
%   modify  -  Feng Zhou (zhfe99@gmail.com), 10-09-2011

% specified in addPath.m
global footpath;
foldpath = sprintf('%s/data/cmum', footpath);
matpath = sprintf('%s/cmum.mat', foldpath);

% if mat existed, just load
if exist(matpath, 'file')
    CMUM = matFld(matpath, 'CMUM');
    prIn('cmumHuman', 'old');
    prOut;
    return;
end
prIn('cmumHuman', 'new');

% all subject
tags = getAllNames;

m = length(tags);

for i = 1 : m
    tag = tags{i};
    
    matpathi = sprintf('%s/%s/label/st.mat', foldpath, tag);
    Tmp = load(matpathi);
    
    % markers' position
    Xis = Tmp.P;
    
    for i = 1 : length(Xis)
        Xis{i} = Xis{i}';
    end
    
    % store
    CMUM.(tag).XTs = Xis;
end

% save
save(matpath, 'CMUM');

prOut;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tags = getAllNames
% Obtain all names under the folder data/cmum.
%
% Output
%   tags  -  names, 1 x m (cell)

tags = {'house'};

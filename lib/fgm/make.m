path0 = cd;

cd 'lib/cell';
mex cellss.cpp;
mex oness.cpp;
mex zeross.cpp;
cd(path0);

cd 'lib/matrix';
mex multGXH.cpp;
cd(path0);

% cd 'src/asg/smac/graph_matching_SMAC';
% compileDir;
% cd(path0);

cd 'src/asg/hun';
mex assignmentoptimal.cpp;
mex mex_normalize_bistochastic.cpp;
cd(path0);

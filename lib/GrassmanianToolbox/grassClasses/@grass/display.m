function display(obj)
% DISPLAY  -  display object information.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

if ~isempty(obj.dim)
    fprintf(1, '%s is a point on a Grassmann manifold of size %s x %s\n',...
        inputname(1), int2str(obj.dim(1)),int2str(obj.dim(2)));
else
     fprintf(1, '%s is not initiated\n',...
        inputname(1));
end
function display(obj)
% DISPLAY  - display object information. 
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

fprintf(1, '%s is a %s-manifold with dimensions\n',...
    inputname(1), int2str(obj.prodSize));
for i = 1:obj.prodSize
    val = get(obj.grass{i},'dim');
    if ~isempty(val)
        fprintf(1, 'manifold %s is of size %s x %s\n',...
            int2str(i), int2str(val(1)), int2str(val(2)));    
    else
        fprintf(1,'%s is not initiated\n',inputname(1));
    end
end
function g = set(g,varargin)
% SET  -  Set specified properties of a grass object.
%
% Properties are: dim, data, base, proj, 
%                 tan, tan2, rtan, rtan2, 
%                 svd, rsvd
%
% Examples, g grass object, D orthonormal matrix, T tangent vector
%   g = set(g, 'data', D)
%   g = set(g, 'data', D, 'tan', T)
% 
% Copyright 2008.
% Berkant Savas, Linköping University.


propertyArgIn = varargin;
while length(propertyArgIn) >= 2
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
       case 'dim'
           g.dim = val;
       case 'data'
           g.data = val;
           if isempty(g.dim)
               g.dim = size(val);
           end
       case 'base'
           [Q,r] = qr(val);           
           g.base = Q(:,g.dim(2)+1:end);
       case 'proj'           
           g.proj = eye(size(val,1))- val*val';
       case 'tan'
           g.tan = val;
           [U,S,V] = svd(val,'econ');
           s = struct('U',U,'S',S,'V',V);
           g.svd = s;
       case 'tan2'
           g.tan2 = val;          
       case 'rtan' 
           g.rtan = val;
           [U,S,V] = svd(val,'econ'); 
           s = struct('U',U,'S',S,'V',V);
           g.rsvd  = s;
       case 'rtan2'
           g.rtan2 = val;
       case 'svd'
           g.svd = val;
       case 'rsvd'
           g.rsvd = val;
       otherwise
           error('Invalid property of grass object.');
   end
end
function obj = grass(varargin)
% GRASS  -  Create Grassmann-manifold object.
%
% Class constructor for Grassmann-manifold objects.   
% Object properties: 
% dim, data, base, proj, tan, rtan, tan2, rtan2, svd and rsvd.
%  
% Examples
%   g = grass()             Create empty grass object
%   g = grass(grassObject)  Copy a grass object
%   g = grass([5,2])        Create a grass object with dimensions 5 x 2
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

%% No arguments: Default constructor
if nargin == 0,			                        
  obj.dim  = [];    % dimensions
  obj.data = [];    % point on manifold, orthogonal matrix of size dim
  obj.base = [];    % base for the tangent space at the current point
  obj.proj = [];    % projection on tangent spaces in matrix form
  obj.tan  = [];    % tangent vector of movement
  obj.tan2 = [];    % tangent vector (arbitrary) to be transported
  obj.rtan = [];    % local coordinates of tan in tangent space basis 
  obj.rtan2= [];    % local coordinates of tan2 in ---- || ------
  obj.svd  = [];    % SVD of tan, used for geodesic movement
  obj.rsvd = [];    % SVD of the local coordinates of rtan
  obj = class(obj,'grass');
  return;
end;

%% Single argument of same class or manifold dimensions. 
arg = varargin{1};

% See above for explanation of properties. 
if nargin == 1
    obj.dim  = []; 
    obj.data = [];
    obj.base = [];
    obj.proj = [];
    obj.tan  = [];
    obj.tan2 = [];
    obj.rtan = [];
    obj.rtan2= [];
    obj.svd  = [];
    obj.rsvd = [];
    obj = class(obj,'grass');
    
    if strcmp(class(arg),'grass')  
        % Copy constructor, copy properties if non-empty. 
        if ~isempty(arg.dim), 		 
            obj.dim = arg.dim;
        end
        if ~isempty(arg.data),
            obj.data = arg.data;
        end
        if ~isempty(arg.base)
            obj.base = arg.base;
        end
        if ~isempty(arg.proj)
            obj.proj = arg.proj;
        end
        if ~isempty(arg.tan),
            obj.tan = arg.tan;
        end        
        if ~isempty(arg.tan2)
            obj.tan2 = arg.tan2;
        end
        if ~isempty(arg.rtan),
            obj.rtan = arg.rtan;
        end
        if ~isempty(arg.rtan2),
            obj.rtan2 = arg.rtan2;
        end
        if ~isempty(arg.svd),
            obj.svd = arg.svd;
        end 
        if ~isempty(arg.rsvd),
            obj.rsvd = arg.rsvd;
        end
    elseif sum(size(arg) == [1 2]) == 2 && arg(1) > arg(2) && ...
            rem(arg(1),1) == 0 && rem(arg(2),1) == 0
        % Dimensions input.
        obj.dim = arg;
    else
        % Error if argument is not hmgrassmann object or shape.
        error('Function called with illegal arguments!');
    end
    return
end

%% Other cases: Something is wrong!
error('Function called with illegal arguments!');


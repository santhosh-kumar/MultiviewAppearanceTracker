function obj = prodGrass(varargin)
% prodGrass   - Constructor for product of Grassmann (grass) objects.
% function obj = prodGrass(varargin)
%
%      Constructor for the class of product of Grassmann
%      points and tangents.
%
% G = prodGrass(3)
% creates a prodGrass object with 3 Grassmann (grass) objects.
% Dimensions of grass-objects are not specified.
%
% With n = [8 9 7]' and k = [3 3 3]'
% G = prodGrass(n,k)
% creates a product of 3 Grassmannians Gr(8,3), Gr(9,3) and Gr(7,3).
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

%% prodGrass constructor
switch nargin
    case 1
        % First case: input argument is an integer.
        p = varargin{1};
        for i = 1:p
            obj.grass{i} = grass();
        end
        obj.prodSize = p;
        obj = class(obj,'prodGrass');
    case 2
        % Second case: input arguments are two vectors n and k
        % of same dimension and integer values, k < n.
        % n and k give the dimension of the Grassmannians.
        n = varargin{1};
        k = varargin{2};
        for i= 1:size(n,1)
            obj.grass{i} = grass([n(i),k(i)]);
        end
        obj.prodSize = size(n,1);
        obj = class(obj,'prodGrass');
    otherwise
        error('Function called with illegal arguments!');
end


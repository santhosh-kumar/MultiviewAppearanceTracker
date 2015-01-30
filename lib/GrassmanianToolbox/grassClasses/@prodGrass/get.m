function val = get(G, propName)
% GET Get prodGrass properties from the specified object
% and return the value
% Example: get the current point X or the second tangnet vector.
% X  = get(G,'data');
% D2 = get(G,'tan2');
% The results are cell arrays of the size of the product manifold.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

%% 
switch propName
    case 'data'
        % Get the current point X.
        for i = 1:G.prodSize
            val{i} = get(G.grass{i},'data');
        end
    case 'base'
        % Get the basis matrix for the tangent space of X.
        for i = 1:G.prodSize
            val{i} = get(G.grass{i},'base');
        end
    case 'proj'
        % Get the projection matrix I - X X^T
        for i = 1:G.prodSize
            val{i} = get(G.grass{i},'proj');
        end
    case 'tan'
        % Get the first tangent vector D (direction of movement).
        for i = 1:G.prodSize
            val{i} = get(G.grass{i},'tan');
        end
    case 'tan2'
        % Get the second tangent vector D2.
        for i = 1:G.prodSize
            val{i} = get(G.grass{i},'tan2');
        end
    case 'rtan'
        % Get the first tangent vector in local coordinates
        for i = 1:G.prodSize
            val{i} = get(G.grass{i},'rtan');
        end
    case 'rtan2'
        % Get the second tangent vector in local coordinates
        for i = 1:G.prodSize
            val{i} = get(G.grass{i},'rtan2');
        end
    case 'svd'
        % Get the svd factors of the first tangent vector in global 
        % coordinates. The results is a cell array with struct-objects. 
        for i = 1:G.prodSize
            val{i} = get(G.grass{i},'svd');
        end
    case 'rsvd'
        % Get the svd factors of the second tangent vector in local 
        % coordinates. The result is a cell array with struct-objects. 
        for i = 1:G.prodSize
            val{i} = get(G.grass{i},'rsvd');
        end
    case 'prodSize'
        % Get the size of the product of Grassmannians.
        val = G.prodSize;
    otherwise
        error([propName,' Is not a valid grass property'])
end
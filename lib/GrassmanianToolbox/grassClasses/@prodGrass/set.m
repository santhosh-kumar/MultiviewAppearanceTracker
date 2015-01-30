function G = set(G,varargin)
% SET Set prodGrass properties and return the updated object
% Example: G prodGrass object and set new data point X
% G = set(G,'data',X);
% 
% Set several objects: new point X, and a tangent vector D. 
% G = set(G,'data',X,'tan',D)
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

propertyArgIn = varargin;
while length(propertyArgIn) >= 2,
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    switch prop
        case 'data'
            % Set the data-point on a product of Grassmannians.
            % It is required that X{i}^T X{i} = I, no impliciti checks
            % are made.
            for i = 1:G.prodSize
                G.grass{i} = set(G.grass{i},'data',val{i});
            end
        case 'base'
            % Set the basis X_perp{i} for the tangent space at the current point.
            % X_perp{i} is orthogonal to X{i}
            for i = 1:G.prodSize
                G.grass{i} = set(G.grass{i},'base',val{i});
            end
        case 'proj'
            % Set the projection matrix I - X{i} X{i}^T on the tangent space
            for i = 1:G.prodSize
                G.grass{i} = set(G.grass{i},'proj',val{i});
            end
        case 'tan'
            % Set a tangent vector D{i} at the current point X{i}.
            % It is required that X{i}^T D{i} = 0 and D{i} is in global
            % coordinates. When the current point is moved it is moved
            % along the geodesic given by this tangent vector.
            for i = 1:G.prodSize
                G.grass{i} = set(G.grass{i},'tan',val{i});
            end
        case 'tan2'
            % Set a second tangent vector D2{i} at the current point X{i}.
            % It is required that X{i}^T D2{i} = 0.
            for i = 1:G.prodSize
                G.grass{i} = set(G.grass{i},'tan2',val{i});
            end
        case 'rtan'
            % Set a tangent vector in local coordinates d{i}.
            % The relation to global coordinates is given by
            % D{i} = X_perp{i} d{i}.
            for i = 1:G.prodSize
                G.grass{i} = set(G.grass{i},'rtan',val{i});
            end
        case 'rtan2'
            % Set a second tangent vector in local coordinates d2{i}.
            for i = 1:G.prodSize
                G.grass{i} = set(G.grass{i},'rtan2',val{i});
            end
        otherwise
            error('Grass properties: data')
    end
end
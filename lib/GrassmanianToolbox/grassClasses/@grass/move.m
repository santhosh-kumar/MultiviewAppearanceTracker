function g = move(g,t,prop)
% MOVE  -  move the data point and/or 
% parallel transport tangent vectos. 
%
% Examples, g grass object, t is the step size, and prop is one of 
%           'p'     - move only the data point, 
%           'ptt'   - move the point and parallel transport both 
%                     tangent vectors, 
%           'pb'    - move the data point and update the basis.
%
%
%   g = move(g, t, 'p')
%   g = move(g, t, 'ptt')
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

X   = g.data;  
switch prop
    case 'p'
        s = g.svd;
        X = movePoint(X,s,t);
        X = orthonormalize(X);
        g.data = X;
    case 'ptt'
        s   = g.svd;
        X = movePoint(X,s,t);
        X = X * s.V';
        T = [g.data*s.V s.U]*[-diag(sin(t*diag(s.S)));
            diag(cos(t*diag(s.S)));];
        X = orthonormalize(X);
        g.data = X;
        g = moveTan(T,g,s);
        g = moveTan2(T,g,s);
    case 'pb'
        B = g.base;
        s = g.rsvd;
        T1  = X*s.V;
        T2  = B*s.U;
        X = movePoint2(T1,T2,s,t);
        B = moveBase(B,T1,T2,s,t);
        X = orthonormalize(X);
        g.data = X;
        g.base = B;
    otherwise
        error('Available properties are, p, ptt ,and pb.')
end


function X = movePoint(X,s,t)
% Move the data point g.data along geodesic given by g.tan
% without the V-matrix multiplied from the right, Edelman98:327

X  = X*s.V*diag(cos(t*diag(s.S))) +  s.U*diag(sin(t*diag(s.S)));

function X = movePoint2(T1,T2,s,t)
% Move the data point g.data along geodesic given by g.tan
% with the V-matrix multiplied from the right. Keep the base in 
% the process.

X = (T1*diag(cos(t*diag(s.S))) + T2*diag(sin(t*diag(s.S))))*s.V';


function B = moveBase(B,T1,T2,s,t)
% Move the base for the tangent plane.

B = ( T1*diag(-sin(t*diag(s.S))) + T2*diag(cos(t*diag(s.S))))*s.U' + ...
    + B - T2*s.U';

function g = moveTan(T,g,s)
% Move tangent vector g.tan along the geodesic given by g.tan.
% The SVD of g.tan at the new point is also computed and updated.
if ~isempty(g.tan) 
    g.tan = T * s.S * s.V';
    [U,S,V] = svd(g.tan,'econ');
    g.svd   = struct('U',U,'S',S,'V',V); 
else 
    error('First tangent vector is not defined!')
end

function g = moveTan2(T,g,s)
% Move tangent vector g.tan2 along the geodesic given by g.tan

if  ~isempty(g.tan2)    
    T2 = s.U'*g.tan2;
    g.tan2  = T*T2 + g.tan2 - s.U*T2;
else 
    error('Second tangent vector is not defined!')
end


function X = orthonormalize(X)
% Reorthogonalize if not on the manifold. 
if abs(norm(X'*X - eye(size(X,2)),'fro')) > 1e-12
    X = orth(X);  
    disp('---------------- X orthonormalized --------------')
end



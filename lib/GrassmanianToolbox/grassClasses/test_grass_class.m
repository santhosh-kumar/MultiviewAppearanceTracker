% This file contains examples of operations on 
% grass-class objects.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

clear 

%% Initiate necessary variables
n = 5; 
r = 2;

X  = orth(randn(n,r));  % A point on Gr(n,r)

% Global coordinates for two tangents.
Tg  = (eye(n) - X*X')*randn(n,r);     
Tg2 = (eye(n) - X*X')*randn(n,r);
% Declare the grass-object and initiate some fields. 
g = grass([n,r])
g = set(g,'data',X)
g = set(g,'tan',Tg, 'tan2',Tg2,'base',X)


Xp = get(g,'base');
% Local coordinate for the two tangents.
Tl  = Xp'*Tg;
Tl2 = Xp'*Tg2;


%% Tests and operations.
get(g,'data')
% The svd of first tangent is already set!  
s = get(g,'svd')        
% Verify this is the case
norm( s.U*s.S*s.V' - get(g,'tan') )

% Compute the norm of first and second tangent.
norm(g,'tan')
norm(g,'tan2')
%norm(g,'rtan2')         % rtan2-field not yet defined.
g = set(g,'rtan2',Tl2)
norm(g,'rtan2')

% Compute the inner product between the first and second tangent.
innerProd(g)

%% Move operations

% t is the step length
t = 0.5;                

% Move just the point X.
g2 = move(g,t,'p')
X2 = get(g2,'data')
% X2 is a point on the manifold!
X2'*X2

% But tangents in g2 are not transported!
X2'*get(g2,'tan')
X2'*get(g2,'tan2')

% Nor the basis matrix is transproted.
X2'*get(g2,'base')

% Now move the point ant both tangents.
g3 = move(g,t,'ptt');
X3 = get(g3,'data')

% Now tangents are transported and of courese they 
% are orthogonal to the current point.
X3'*get(g3,'tan')
X3'*get(g3,'tan2')

% Compute the inner product again, and compare with 
% the computation at the previous point: innerProd(g) 
innerProd(g3)

% Move the point and the basis matrix.

% First set the first tangent (direction of movement) 
% in local coordinates. The rsvd-field is set automatically.
g = set(g,'rtan',Tl);       
g4 = move(g,t,'pb');
X4 = get(g4,'data');
X4'*get(g4,'base')
% The matrices X2,X3,X4 represent the same point/subspce 
subspace(X2,X3)
subspace(X2,X4)

% But X2 is different from X3 and X4.
X2-X3

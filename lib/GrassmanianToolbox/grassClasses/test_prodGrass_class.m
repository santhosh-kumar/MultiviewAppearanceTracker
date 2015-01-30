% This file contains examples of operations on 
% prodGrass-class objects.
% 
% Copyright 2008.
% Berkant Savas, Linköping University.

clear 

%% Initiate variables
n = [9, 5, 6]'; 
r = [4, 2, 3]';

% Initiate point on a product of Grassmannians and 
% compute global coordinates for the tangents.
for i = 1:size(n,1)
    X{i}  = orth(randn(n(i),r(i))); 
    Tg{i}  = (eye(n(i)) - X{i}*X{i}')*randn(n(i),r(i));     
    Tg2{i} = (eye(n(i)) - X{i}*X{i}')*randn(n(i),r(i));
end

% Declare the prodGrass-object and initiate some fields.
G = prodGrass(n,r);
G = set(G,'data',X);
G = set(G,'tan',Tg, 'tan2',Tg2,'base',X);

Xp = get(G,'base');
% Compute local coordinates for the tangents.
for i = 1:size(n,1)
    Tl{i}  = Xp{i}'*Tg{i};
    Tl2{i} = Xp{i}'*Tg2{i};
end

%% Tests and operations.
get(G,'data')
% The svd of first tangent is already set!  
s = get(G,'svd') 

% Compute the norm of first and second tangent.
norm(G,'tan')
norm(G,'tan2')
G = set(G,'rtan2',Tl2)
norm(G,'rtan2')

% Compute the inner product between the first and second tangent.
innerProd(G)

%% Move operations

% t is the step length
t = 0.5;                

% Move just the point X.
G2 = move(G,t,'p');
X2 = get(G2,'data');

% Now move the point ant both tangents.
G3 = move(G,t,'ptt');
X3 = get(G3,'data')

% Compute the inner product again, and compare with 
% the computation at the previous point: innerProd(g) 
innerProd(G3)

% Move the point and the basis matrix.

% First set the first tangent (direction of movement) 
% in local coordinates. The rsvd-field is set automatically.
G = set(G,'rtan',Tl);       
G4 = move(G,t,'pb');
X4 = get(G4,'data');


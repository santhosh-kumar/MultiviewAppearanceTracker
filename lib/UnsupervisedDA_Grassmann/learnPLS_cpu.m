function [T,P,W,Wstar,b,Xdata]= learnPLS_cpu(X,Y,numFactor)
% [T,P,W,Wstar,Xdata,Ydata]= learnPLS(X,Y,numFactor)
% PLS - NIPALS algorithm
% Compute the PLS coefficients
% Inputs:
%  X         - training data, N x d
%  Y         - training label, N x f
%  numFactor - number of PLS factors
% Outputs: 
%  T        - Input projections, N x numFactor
%  P        - N x numFactor
%  W        - d x numFactor
%  Wstar    - Projection matrix, d x numFactor
%  Xdata    - Mean and SD of X (struct)
%  Ydata    - Mean and SD of Y (struct)


T=[];P=[];W=[];Wstar=[];U=[];b=[];C=[];R2_X=[];R2_Y=[];

% Checking to see if any feature is all the same
stdX = std(X);
fstd0 = find(stdX==0);
X(end,fstd0)=X(end,fstd0)+1e-10;

if exist('numFactor')~=1;numFactor=rank(X);end

M_X=mean(X);
M_Y=mean(Y);
S_X=std(X);
S_Y=std(Y);

Xdata.mean = M_X;
Xdata.std = S_X;
Ydata.mean = M_Y;
Ydata.std = S_Y;

X=zscorem(X, M_X, S_X);
Y=zscorem(Y, M_Y, S_Y);

Xnorm = X;
Ynorm = Y;

[nn,np]=size(X);
[n,nq]=size(Y);
if nn~= n;
    error(['Incompatible # of rows for X and Y']);
end
% Initialistion
% The Y set
U=zeros(n,numFactor);
C=zeros(nq,numFactor);
% The X set
T=zeros(n,numFactor);
P=zeros(np,numFactor);
W=zeros(np,numFactor);
b=zeros(1,numFactor);
R2_X=zeros(1,numFactor);
R2_Y=zeros(1,numFactor);

Xres=X;
Yres=Y;
SS_X=sum(sum(X.^2));
SS_Y=sum(sum(Y.^2));

for l=1:numFactor    
    [w,t,c,u,p]=iteration(n,Xres,Yres);
    b_l=((t'*t)^(-1))*(u'*t);
    b(l)=b_l;
    P(:,l)=p;
    W(:,l)=w;
    T(:,l)=t;
    U(:,l)=u;
    C(:,l)=c;
    % deflation of X and Y
    Xres=Xres-t*p';
    Yres=Yres-(b(l)*(t*c'));
    R2_X(l)=(t'*t)*(p'*p)./SS_X;
    R2_Y(l)=(t'*t)*(b(l).^2)*(c'*c)./SS_Y;
end

% The Wstart weights gives T=X*Wstar
%
Wstar=W*inv(P'*W);

%%%%%%%%%%%%%  Functions Here %%%%%%%%%%%%%%%%%%%%%%%
function [f]=normaliz(F)
%USAGE: [f]=normaliz(F);
% normalize send back a matrix normalized by column
% (i.e., each column vector has a norm of 1)
[ni,nj]=size(F);
v=ones(1,nj) ./ sqrt(sum(F.^2));
f=F*diag(v);

function z=zscorem(x,m,s)
% USAGE function z=zscore(x);
% gives back the z-normalization for x
% if X is a matrix Z is normalized by column
% Z-scores are computed with
% sample standard deviation (i.e. N-1)
% see zscorepop
[ni,nj]=size(x);
%m=mean(x);
%s=std(x);
un=ones(ni,1);
z=(x-(un*m))./(un*s);

function [w,t,c,u,p]=iteration(n,Xres,Yres)
% Precision for convergence
epsilon=eps;
t=normaliz(Yres(:,1));
t0=normaliz(rand(n,1)*10);
u=t;
nstep=0;
maxstep=100;
while ( ( (t0-t)'*(t0-t) > epsilon/2) & (nstep < maxstep));
    nstep=nstep+1;
    t0=t;
    w=normaliz(Xres'*u);
    t=normaliz(Xres*w);
    c=normaliz(Yres'*t);
    u=Yres*c;
end;
p=Xres'*t;

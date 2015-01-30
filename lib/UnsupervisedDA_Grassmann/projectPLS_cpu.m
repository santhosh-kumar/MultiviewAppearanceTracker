function [WX]= projectPLS_cpu(X,W,Xdata)
% function [WX]= projectPLS_cpu(X,W,Xdata)
% PLS projection
% Inputs:
%  X         - training data, N x d
%  W         - projection matrix, d x f
%  Xdata     - mean and std of X, Xdata.mean & Xdata.std
%
%  Outputs: 
%  WX        - Projections X x W, N x f
%

X=zscorem(X,Xdata.mean,Xdata.std);
WX=X*W;

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

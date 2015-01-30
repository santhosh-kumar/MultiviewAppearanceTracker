function [Cx, Fx, weak_output] = strongGentleClassifier(x, classifier)
% [Cx, Fx] = strongLogitClassifier(x, classifier)
%
% Cx is the predicted class 
% Fx is the output of the additive model
% Cx = sign(Fx)
%
% In general, Fx is more useful than Cx.
%
% The weak classifiers are stumps

% Friedman, J. H., Hastie, T. and Tibshirani, R. 
% "Additive Logistic Regression: a Statistical View of Boosting." (Aug. 1998) 

% atb, 2003
% torralba@ai.mit.edu

Nstages = numel(classifier);

% Each feature is a column vector
[Nfeatures, Nsamples] = size(x); % Nsamples = Number of thresholds that we will consider

Fx = zeros(1, Nsamples);
weak_output = zeros(Nstages, Nsamples);
for m = 1:Nstages % Number of classifiers
    featureNdx = classifier{m}.featureNdx; % The dimension in which the stump is present
    th = classifier{m}.th;                 % Threshold for the classifier in that dimension
    a =  classifier{m}.a;                  % slope of the line
    b =  classifier{m}.b;                  % intercept of the line
    
    % x(featureNdx,:) corresponds to each every dimension
    weak_output(m, :) = (a * (x(featureNdx,:)>th) + b);
    Fx = Fx + weak_output(m, :); %add regression stump
    
end

Cx = sign(Fx);

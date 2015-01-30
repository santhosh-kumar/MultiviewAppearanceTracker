function [featureNdx, th, a , b, error] = selectBestRegressionStump(x, z, w);
% [th, a , b] = fitRegressionStump(x, z);
% z = a * (x>th) + b;
% where (a,b,th) are so that it minimizes the weighted error:
% error = sum(w * |z - (a*(x>th) + b)|^2) / sum(w)
% atb, 2003 torralba@ai.mit.edu
[Nfeatures, Nsamples] = size(x); % Nsamples = Number of thresholds that we will consider
w = w/sum(w); % just in case...
th = zeros(1,Nfeatures);
a = zeros(1,Nfeatures);
b = zeros(1,Nfeatures);
error = zeros(1,Nfeatures);

for n = 1:Nfeatures % Iterates through the total number of dimensions ...
    [th(n), a(n) , b(n), error(n)] = fitRegressionStump(x(n,:), z, w);
end

[error, featureNdx] = min(error);
th = th(featureNdx);
a = a(featureNdx);
b = b(featureNdx);

function [th, a , b, error] = fitRegressionStump(x, z, w);
% The regression has the form:
% z_hat = a * (x>th) + b;
% where (a,b,th) are so that it minimizes the weighted error:
% error = sum(w * |z - (a*(x>th) + b)|^2) 
% x,z and w are vectors of the same length x, and z are real values. w is a weight of positive values. 
% There is no asumption that it sums to one.
% atb, 2003

[Nfeatures, Nsamples] = size(x); % Nsamples = Number of thresholds that we will consider
w = w/sum(w); % just in case...

[x, j] = sort(x); % this now becomes the thresholds. I assume that all the values are different. If the values are repeated you might need to add some noise.
z = z(j); w = w(j);

Szw = cumsum(z.*w); Ezw = Szw(end);
Sw  = cumsum(w);

% This is 'a' and 'b' for all posible thresholds:
b = Szw ./ Sw;
zz = Sw == 1;
Sw(zz) = 0; 
a = (Ezw - Szw) ./ (1-Sw) - b; 
Sw(zz) = 1;
% the error at each threshold is:
% for i=1:Nsamples,   error(i) = sum(w.*(z - ( a(i)*(x>th(i)) + b(i)) ).^2); end
Error = sum(w.*z.^2) - 2*a.*(Ezw-Szw) - 2*b*Ezw + (a.^2 +2*a.*b) .* (1-Sw) + b.^2;
% Output parameters. Search for best threshold (th):
[error, k] = min(Error);
if k == Nsamples
    th = x(k);
else
    th = (x(k) + x(k+1))/2;
end
a = a(k);
b = b(k);
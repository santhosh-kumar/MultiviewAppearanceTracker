function Xorth=computeXorthonormal(X);
% Timothee Cour, 21-Apr-2008 17:31:23
% This software is made publicly for research use only.
% It may be modified and redistributed under the terms of the GNU General Public License.

[n1,n2,k]=size(X);
Xorth = zeros(n1,n2,k);
for i=1:k
    Xorth(:,:,i)=computeXorthonormal_aux(X(:,:,i));
end

function Xorth=computeXorthonormal_aux(X);
[n1,n2]=size(X);
[U,S,V] = svd(X);

Xorth = U*eye(n1,n2)*V';


function [Xd,ind1,ind2] = computeDiscreteCorrespondancesGreedy(X,E12,W);
% Timothee Cour, 21-Apr-2008 17:31:23
% This software is made publicly for research use only.
% It may be modified and redistributed under the terms of the GNU General Public License.

assert(~any(isnan(X(:))));

[n1,n2,nb] = size(X);
if nb~=1
    error('nb~=1');
end
if nargin<2
    E12=ones(n1,n2);
end

Xd = zeros(n1,n2);
% L = true(n1,n2);
L = E12>0;
[val_X,ind_X]=sort(X(:),'descend');
ind_X=int32(ind_X);
k=1;
while 1
    k=mex_find_next_nonzero(L,ind_X,k);
%     while L(ind_X(k))==0
%         k=k+1;
%     end
    ind=ind_X(k);
    val=val_X(k);
    
    Xd(ind) = 1;
    [indi,indj] = mex_ind2sub([n1,n2],ind);
    L(:,indj) = 0;
    L(indi,:) = 0;
%     if val==0
%         break;
%     else
%         Xd(ind) = 1;
%         [indi,indj] = mex_ind2sub([n1,n2],ind);
%         L(:,indj) = 0;
%         L(indi,:) = 0;
%     end
    if ~any(L(:))
        break;
    end
end

[ind1,ind2] = find(Xd);


% Xd = zeros(n1,n2);

%{
minX_minus1=min(X(:))-1;
if minX_minus1>=0
    minX_minus1 = -1;
end
while 1
    [val,ind] = max(X(:));
    if val<=0 %val<=minX_minus1 ??
        break;
    else
        Xd(ind) = 1;
        [indi,indj] = ind2sub2([n1,n2],ind);
        X(:,indj) = minX_minus1;
        X(indi,:) = minX_minus1;
    end
end
%}


%{
Xd = zeros(n1,n2);
L = true(n1,n2);
while 1
%     temp = find(L(:));
    temp = find(L);
    [val,ind] = max(X(temp));
    ind = temp(ind);
    if val==0
        break;
    else
        Xd(ind) = 1;
        [indi,indj] = ind2sub2([n1,n2],ind);
        %     L(ind) = 0;
        L(:,indj) = 0;
        L(indi,:) = 0;
    end
    if ~any(L(:))
        break;
    end
end
%}

function W = trilW2W(W);
% Timothee Cour, 21-Apr-2008 17:31:23
% This software is made publicly for research use only.
% It may be modified and redistributed under the terms of the GNU General Public License.

if issparse(W)
    temp=spdiag(diag(W));
else
    temp=diag(diag(W));
end
W = W + W';
W=W-temp;

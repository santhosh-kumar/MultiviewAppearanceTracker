% TESTS 
clear 
n = [7 10 9 8 20]';
r = [2 3 4 2 4]';

A = tensor(randn(n'));

G = prodGrass(n,r);
for i = 1:size(n,1)
    X{i} = orth(randn([n(i),r(i)]));
end

G = set(G,'data',X,'proj',X);


g = dF(A,G,'p')

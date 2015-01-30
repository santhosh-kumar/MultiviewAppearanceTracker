clear all;
close all;
clc;

addpath( '../ihog-master' );
addpath( '../pdollar_toolbox_301' );

im1 = double(imread('view1.png')) / 255.;
im2 = double(imread('view2.png'))/ 255.;

F1 = features(im1, 8);
F2 = features(im2, 8);

ihog1 = invertHOG(F1);
ihog2 = invertHOG(F2);

% figure(1);
% clf;
% 
% subplot(131);
% imagesc(im1); axis image; axis off;
% title('Original Image', 'FontSize', 20);
% 
% subplot(132);
% showHOG(F1); axis off;
% title('HOG Features', 'FontSize', 20);
% 
% subplot(133);
% imagesc(ihog1); axis image; axis off;
% title('HOG Inverse', 'FontSize', 20);
% 
% figure(2);
% clf;
% 
% subplot(131);
% imagesc(im2); axis image; axis off;
% title('Original Image', 'FontSize', 20);
% 
% subplot(132);
% showHOG(F2); axis off;
% title('HOG Features', 'FontSize', 20);
% 
% subplot(133);
% imagesc(ihog2); axis image; axis off;
% title('HOG Inverse', 'FontSize', 20);

% convert to feature vectors
X1 = [];
for i = 1 : size( F1, 1 )
    for j = 1 : size( F1, 2 )
    f = F1(i,j,:);
    X1 = [ X1; f(:)'];
    end
end

% convert to feature vectors
X2 = [];
for i = 1 : size( F2, 1 )
    for j = 1 : size( F2, 2 )
    f = F2(i,j,:);
    X2 = [ X2; f(:)'];
    end
end


d = 15;
n = length(f);
t = [0.1 : 0.05: 1];

% apply pca
[U1, mu1, var1] = pca(X1);
[ S1, X1hat, avsq1 ] = pcaApply( X1, U1, mu1, d );
S1 = S1'; % n x d

[U2, mu2, var2] = pca(X2);
[ S2, X2hat, avsq2 ] = pcaApply( X2, U2, mu2, d );
S2 = S2'; % n x d

% compute the direction and speed of geodesic flow
A = compute_velocity_grassmann_efficient(S1, S2); %(n-d) x d

% compute intermediate subspaces
for k = 1 : length(t)
    
    S1a = compute_Y_havingVelocity( S1, A, t(k));
    [ X1a ] = pcaReconstruct( S1a, X1, U1, mu1, d );
    
    F1a = zeros(size( F1, 1 ) , size( F1, 2 ),  size( F1, 3 ));
    startIndex = 0;
    for i = 1 : size( F1, 1 )
        for j = 1 : size( F1, 2 )
            index = startIndex + j;
            F1a(i,j,:) = X1a( index, : );
        end

        startIndex = startIndex + j;
    end

    ihog1a = invertHOG(F1a);

    figure;
    clf;
    
    titleString = ['t=' num2str(t(k))];
    title(titleString);
    subplot(131);
    imagesc(im1); axis image; axis off;
    title('Original Image', 'FontSize', 20);

    subplot(132);
    showHOG(F1a); axis off;
    title('HOG Features', 'FontSize', 20);

    subplot(133);
    imagesc(ihog1a); axis image; axis off;
    title([ 'HOG Inverse' titleString], 'FontSize', 20);

end


    


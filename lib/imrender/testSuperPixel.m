clear all;
close all;
clc;

im=imread('img16337.png');
im=imread('9061_1.png');
% tic;
% S=vgg_segment_ms(im,5,5,20);
% toc;
% op=shuffleSupInd(S);
% imshow(op);

% ratio = 0.5;
% kernelsize = 2;
% maxDist = 10;
% Iseg = vl_quickseg(im, ratio, kernelsize, maxDist);
% imagesc(Iseg);

I = imread('img16337.png');
im = im2single(I) ;
imlab = vl_xyz2lab(vl_rgb2xyz(im)) ;
segments = vl_slic(single(im), 35, 0.01) ;
[sx,sy]=vl_grad(double(segments), 'type', 'forward') ;
s = find(sx | sy) ;
imp = im ;
imp([s s+numel(im(:,:,1)) s+2*numel(im(:,:,1))]) = 255 ;
imshow(imp);

boxes=regionprops(uint8(imp),'BoundingBox');
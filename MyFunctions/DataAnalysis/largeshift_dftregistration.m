function tform = largeshift_dftregistration(im_ref,im_moving)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
im_ref = double(im_ref);
im_moving = double(im_moving);

CC = normxcorr2(im_ref,im_moving);

% create laplacian of gaussian kernel
sig = 2;
W = ceil(4*sig);
x = -W:W;
y = -W:W;
[X,Y] = meshgrid(x,y);
LoG = (1/(pi*sig^4))*(1-(Y.^2+X.^2)/(2*sig^2)).*exp(-(X.^2+Y.^2)/(2*sig^2));

absCC = abs(conv2(CC, LoG, 'same'));

sz = size(im_ref);

[ypeak, xpeak] = find(absCC==max(absCC(:)));

yoffSet = ypeak-sz(1);
xoffSet = xpeak-sz(2);

tform = affine2d([1 0 0; 0 1 0;  -xoffSet -yoffSet 1]);


% % plot absCC
% figure(1000)
% clf
% h = surf(absCC)
% view([0 90])
% h.LineStyle = 'none';
% im_fixed = imwarp(im_moving,tform,'OutputView',V);
% 
% figure(1001)
% imshowpair(im_ref,im_fixed)


end


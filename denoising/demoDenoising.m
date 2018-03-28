function demoDenoising()
%% This code demonstrates impulse denoising of hyperspectral images 
% using low rank and total variation.
%It solves following optimization problem
% min_X || Y-X||_1 + lambda ||Dh*X||_1 + lamdba ||Dv*X||_1 + mu ||X||_*
% X: Input hyperspectral image
% Y: Noisy image
% Dh, Dv: Horizontal and vertical finite difference operators
%||X||_* : Nuclear norm of matrix X
% We utilize split-Bregman technique to solve above problem
clc; clear all; clf;
 %% Read the image
load('HyperSpectralPatch'); %it will load 'img' variable
img=im2double(img);

[rows,cols,d]=size(img);
sizex=[rows,cols];

%% Add noise and calculate noisy image psnr
%For different noise levels parameters have to be adjusted.
noisy = imnoise(img,'salt & pepper',0.1);

psnrBefore=myPSNR(img,noisy,1);         
fprintf('\n PSNR before denoising= %f \n',psnrBefore);

y=reshape(noisy,rows*cols,d);  

%% Set parameters and run the algorithm

%mu(1) corresponds to total variation term
%mu(2) corresponds to low rank term
%mu(3) corresponds to data fidelity term
mu=[.2 .2 .5]; iter=10;  % Iteration number
tic
x=funDenoising(y,sizex,mu,iter);
toc

%% Calculate Denoised image PSNR 
psnrRec=myPSNR(img,x,1);         
fprintf('\n PSNR After= %f \n',psnrRec);

%% Display results
bands=[ 1 floor(d/2) d]; %these are the bands to be displayed
%do histogram equilization for display purpose
img=myhisteq(img);rec=myhisteq(x);  noisy=myhisteq(noisy);
subplot(131); imshow(img(:,:,bands)); title('Original Image');
subplot(132); imshow(noisy(:,:,bands)); title('Noisy Image');
subplot(133); imshow(rec(:,:,bands)); title('Reconstructed Image');

end

%% Function for PSNR
function cpsnr=myPSNR(org,recon,skip)

org=org(skip+1:end-skip,skip+1:end-skip,:);
recon=recon(skip+1:end-skip,skip+1:end-skip,:);
[m, n,~]=size(org);
    %this is the sum of square error for each band
    sse=sum(sum((org-recon).^2));   
    mse=sse./(m*n);  %mean square error of each band.
    rmse=sqrt(sum(mse)/numel(mse)); 
    maxval=max( max(abs(org(:))),max(abs(recon(:))));
    
    cpsnr=20*log10(maxval/rmse);
end
%% Function for histogram equilization
function img=myhisteq(img)
[~,~,dim]=size(img);

for i=1:dim
    img(:,:,i)=histeq(img(:,:,i));
end
end
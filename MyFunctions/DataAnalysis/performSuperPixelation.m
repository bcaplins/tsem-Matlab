function [spSegs,skel] = performSuperPixelation(filledDat,size_param,reg_param)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

% reorder and rescale data into 2-D array
[numRows,numCols,numSpectra] = size(filledDat);
scfact = mean(reshape(sqrt(sum(filledDat.^2,3)),numRows*numCols,1));
filledDat = filledDat./scfact;

% compute superpixels
disp('Computing SLIC Superpixels...');
tic; 
spSegs = vl_slic(single(filledDat),size_param,reg_param); 
toc


% display image of superpixels
[sx,sy]=vl_grad(double(spSegs), 'type', 'forward') ;
s = find(sx | sy);

skel = zeros(size(spSegs));
skel(s) = 1;
skel = repmat(skel,[1 1 3]);




end



% BFILTER2 Two dimensional bilateral filtering.
%    This function implements 2-D bilateral filtering using
%    the method outlined in:
%
%       C. Tomasi and R. Manduchi. Bilateral Filtering for 
%       Gray and Color Images. In Proceedings of the IEEE 
%       International Conference on Computer Vision, 1998. 
%
%    B = bfilter2(A,W,SIGMA) performs 2-D bilateral filtering
%    for the grayscale or color image A. A should be a double
%    precision matrix of size NxMx1 or NxMx3 (i.e., grayscale
%    or color images, respectively) with normalized values in
%    the closed interval [0,1]. The half-size of the Gaussian
%    bilateral filter window is defined by W. The standard
%    deviations of the bilateral filter are given by SIGMA,
%    where the spatial-domain standard deviation is given by
%    SIGMA(1) and the intensity-domain standard deviation is
%    given by SIGMA(2).
%
% Douglas R. Lanman, Brown University, September 2006.
% dlanman@brown.edu, http://mesh.brown.edu/dlanman


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre-process input and select appropriate filter.
function B = bfilter2update(A,AMP,w,sigma)

w = ceil(w);
B = bfltColor(A,AMP,w,sigma(1),sigma(2),sigma(3));

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implements bilateral filter for color images.
function B = bfltColor(A,AMP,w,sigma_d,sigma_col,sigma_amp)


% Pre-compute Gaussian domain weights.
[X,Y] = meshgrid(-w:w,-w:w);
G = exp(-(X.^2+Y.^2)/(2*sigma_d^2));


% Create waitbar.
h = waitbar(0,'Applying bilateral filter...');
set(h,'Name','Bilateral Filter Progress');

% Apply bilateral filter.
dim = size(A);
B = zeros(dim);
for i = 1:dim(1)
   for j = 1:dim(2)
      
         % Extract local region.
         iMin = max(i-w,1);
         iMax = min(i+w,dim(1));
         jMin = max(j-w,1);
         jMax = min(j+w,dim(2));
         I = A(iMin:iMax,jMin:jMax,:);
      
         % Compute Gaussian range weights.
         dr = I(:,:,1)-A(i,j,1);
         dg = I(:,:,2)-A(i,j,2);
         db = I(:,:,3)-A(i,j,3);
         
         damp = AMP(iMin:iMax,jMin:jMax);
         
         H = exp(-(dr.^2+dg.^2+db.^2)/(2*sigma_col^2));
         
         K = exp(-(damp.^2)/(2*sigma_amp^2));
      
         % Calculate bilateral filter response.
         F = K.*H.*G((iMin:iMax)-i+w+1,(jMin:jMax)-j+w+1);
         norm_F = sum(F(:));
         B(i,j,1) = sum(sum(F.*I(:,:,1)))/norm_F;
         B(i,j,2) = sum(sum(F.*I(:,:,2)))/norm_F;
         B(i,j,3) = sum(sum(F.*I(:,:,3)))/norm_F;
                
   end
   waitbar(i/dim(1));
end


% Close waitbar.
close(h);
end
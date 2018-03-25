function [fmat,fvec] = calculateCMOScalib(calib_img_dir,fnames,X,semScanParams,PIX_THRESH)

sz = size(X);
if(sz(1) ~= 2)
    error('Must use 2xN matrix')
end

% The supplied directory must end with a slash
if(length(calib_img_dir)>0)
    if(calib_img_dir(end)~='\')
        calib_img_dir = [calib_img_dir '\'];
    end
end

camCoords = zeros(size(X));
for i=1:length(X)
    % Read the image
    fullpath = [calib_img_dir fnames{i}];
    
    mono_img = MonochromeImage(fullpath);
    
    % Threshold to get spots and calculated center of mass
    [ys xs] = find(mono_img.img>PIX_THRESH);       
    camCoords(1,i) = mean(xs);
    camCoords(2,i) = mean(ys);
    
    % Create a stack as you go to show the calibarated image later
    if(i ==1)
        max_img = MonochromeImage();
        max_img.img = mono_img.img;
    else
        max_img.img = max(mono_img.img,max_img.img);
    end
    
    % You can view the individual fits to make sure it is correct
%     figure(gcf)
%     clf
%     plot(mono_img)
%     hold on
%     plot(camCoords(1,i),camCoords(2,i),'ro')
%     axis ij
%     pause(0.001)
    i
end


% Write the stacked image
max_img.saveImageAsPNG([calib_img_dir 'MAX_CMOS_STACK'])

% Create rotation, stretch and scaling operators
rot = ImageMapping.clockwiseRotationMatrixFunction();
sc = @(sx,sy) [sx 0; 0 sy];

% Create the transformation matrix and vector (basically just an affine
% transformation) f(F) = A*X+b
fumat = @(p) rot(p(4))*sc(p(2),p(3))*rot(p(1));
fuvec = @(p) rot(p(4))*sc(p(2),p(3))*rot(p(1))*([p(5) p(6)]');

fu = @(p,x) fumat(p)*x+fuvec(p);

% Function to calculate distances between sets of points
dist = @(A,B) sqrt((A(1,:)-B(1,:)).^2+(A(2,:)-B(2,:)).^2);

% convert beam coords to unrotated spatial coords
yagcoords = zeros(size(X));
for i=1:length(X)
    if(numel(semScanParams) == 1)
        semParam = semScanParams;
    else
        semParam = semScanParams(i);
    end
    yagcoords(:,i) = ImageMapping.mapFromRotatedBeamCoordsToNonrotatedSpatialCoords(X(:,i),semParam);
end

% Penalty function is the sum of the distances between the beam coordinated
% and the trasnformed camera coordinates
OLS = @(p) mean(dist(yagcoords,fu(p,camCoords)).^2);

p0 = 1.0e+03*[0.0023   -0.0101    0.0091    0.0009   -1.0686   -0.4888];

% Do optimization
opts = optimset('MaxFunEvals',100000,'MaxIter',100000,'TolX',1e-6,'TolFun',1e-6);
[popt,fval,exitflag,output] = fminsearch(OLS,p0, opts)

RMS = sqrt(OLS(popt))

% popt = p0;

% Get optimized result
ncamCoords = fu(popt,camCoords);

% Plot the two sets of points to judge the mapping
figure(1)
clf
hold on

plot(yagcoords(1,:),yagcoords(2,:),'r-')
plot(yagcoords(1,1),yagcoords(2,1),'ro')

plot(ncamCoords(1,:),ncamCoords(2,:),'b-')
plot(ncamCoords(1,1),ncamCoords(2,1),'bo')


fmat = fumat(popt);
fvec = fuvec(popt);

% % Save the calibration data
% save([wd 'CALIB_CMOSPIX_TO_BEAMPIX'],'fmat','fvec')




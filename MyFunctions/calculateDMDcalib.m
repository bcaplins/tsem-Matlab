function [gmat,gvec] = calculateDMDcalib(calib_img_dir,fnames,X,PIX_THRESH)

sz = size(X);
if(sz(1) ~= 2)
    error('Must use 2xN matrix')
end

if(numel(PIX_THRESH)>1)
    UPPER_LIM = PIX_THRESH(2);
    PIX_THRESH = PIX_THRESH(1);
else
    UPPER_LIM = inf;
end

% The supplied directory must end with a slash
if(length(calib_img_dir)>0)
    if(calib_img_dir(end)~='\')
        calib_img_dir = [calib_img_dir '\'];
    end
end

camCoords = zeros(size(X));
for i = 1:length(X)        
        
        % Read the image
        fullpath = [calib_img_dir fnames{i}];
        mono_img = MonochromeImage(fullpath);
                
        % Use a 3x3 smoothing kernel to reduce pixel noise
%         mono_img.img = conv2(mono_img.img,ones(3,3)./9,'same');
        
        mono_img.img = movmedian(mono_img.img,5,1);
        mono_img.img = movmedian(mono_img.img,5,2);
        
        
        % Threshold to get spots and calculated center of mass
        [ys xs] = find((mono_img.img>PIX_THRESH) & (mono_img.img<=UPPER_LIM));
        camCoords(1,i) = mean(xs);
        camCoords(2,i) = mean(ys);
        
         % Create a stack as you go to show the calibarated image later
        if(i ==1)
            max_img = MonochromeImage();
            max_img.img = mono_img.img;
        else
            max_img.img = max(mono_img.img,max_img.img);
        end
        
%         % You can view the individual fits to make sure it is correct
        figure(gcf)
        clf
        plot(mono_img)
        hold on
        spy(mono_img.img>PIX_THRESH)
      
        plot(camCoords(1,i),camCoords(2,i),'ro')
        pause(0.1)
%         pause
end

% Write the stacked image
max_img.saveImageAsPNG([calib_img_dir 'MAX_DMD_STACK'])

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

% Penalty function is the sum of the distances between the dmd coordinated
% and the trasnformed camera coordinates
OLS = @(p) sum(dist(X,fu(p,camCoords)));

% Guess paramters
p0 = [0.7679    0.6616    0.7219   -0.7598 -312.3247   34.8519];

% p0 = [-5*pi/180   0.75    0.75   0  -50  -50];

% Do optimization
opts = optimset('MaxFunEvals',100000,'MaxIter',100000);
popt = fminsearch(OLS,p0, opts)

% popt = p0;

% Get optimized result
ncamCoords = fu(popt,camCoords);

% Plot the two sets of points to judge the mapping
figure(1)
clf
hold on

plot(X(1,:),X(2,:),'r-')
plot(X(1,1),X(2,1),'ro')

plot(ncamCoords(1,:),ncamCoords(2,:),'b-')
plot(ncamCoords(1,1),ncamCoords(2,1),'bo')

% Save the calibration data
gmat = fumat(popt);
gvec = fuvec(popt);

% % Save the calibration data
% save([wd 'CALIB_CMOSPIX_TO_DMDPIX'],'gmat','gvec')
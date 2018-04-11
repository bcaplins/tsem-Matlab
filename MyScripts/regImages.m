clear all
close all

X = csvread('positions.csv')*1e3

    
X = X;

width = 14.47
height = width*768/1024

N_seg = 20;

idxs = [3 1 5 7 0 2 6 8]
refidxs = [4 4 4 4 3 5 3 5]
% 
% idxs = [2 1 3]
% refidxs = [0 0 1]

tforms = cell(length(idxs)+1,1);
for i=1:length(idxs)+1
	tforms{i} = affine2d;
end

imageSize = [768 1024];


for i=1:length(idxs)

    
    
    idx = idxs(i);
    refidx = refidxs(i);
    
    dX1 = (X(idx+1,1)/width);
    dY1 = (X(idx+1,2)/height);

    dX2 = (X(refidx+1,1)/width);
    dY2 = (X(refidx+1,2)/height);

    dX = round(1024*(dX2-dX1));
    dY = round(768*(dY2-dY1));

    refIm = double(imread(['gr_series_v1_' sprintf('%0.3d',refidx*(N_seg+2)) '.tif']))/255;
    im = double(imread(['gr_series_v1_' sprintf('%0.3d',idx*(N_seg+2)) '.tif']))/255;
    
    DEL = 150;
    
%     dX = -665;
%     dY = -5;
    
    qs = (dX-DEL):10:(dX+DEL);
    rs = (dY-DEL):10:(dY+DEL);
    [Qs Rs] = meshgrid(qs, rs);
    
    errs = zeros(size(Qs));
    
    for k =1:numel(Qs)
        errs(k) = imageError(refIm,im,[-Rs(k) Qs(k)]);
    end
    
    figure(123124)
    clf
    contourf(Qs,-Rs,errs)
    
    [dum midx] = min(errs(:));
    dX = Qs(midx)
    dY = Rs(midx)
%     
    [optimizer, metric] = imregconfig('monomodal');


    tform0 = affine2d([1 0 0; 0 1 0; dX -dY 1]);

    tform = imregtform(im, refIm, 'translation', optimizer, metric,'InitialTransformation',tform0);
%     movingRegistered = imregister(im, refIm, 'translation', optimizer, metric,'InitialTransformation',tform0);

    tforms{idx+1}.T = tforms{refidx+1}.T * tform.T
    
    figure(1)
    vieww = imref2d(size(im));
    imshowpair(refIm, imwarp(im,tform,'OutputView', vieww),'diff')

    
%     
    
%     imshowpair(refIm, movingRegistered,'diff')

    


%     pause


end

for i=1:length(tforms)
    tforms{i}.T  = round(tforms{i}.T)
end


% Compute the output limits  for each transform
for i = 1:numel(tforms)
    [xlim(i,:), ylim(i,:)] = outputLimits(tforms{i}, [1 imageSize(2)], [1 imageSize(1)]);
end

avgXLim = mean(xlim, 2);

[~, idx] = sort(avgXLim);

centerIdx = floor((numel(tforms)+1)/2);

centerImageIdx = idx(centerIdx);



maxImageSize = imageSize;

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([maxImageSize(2); xlim(:)]);

yMin = min([1; ylim(:)]);
yMax = max([maxImageSize(1); ylim(:)]);

% Width and height of panorama.
width  = round(xMax - xMin);
height = round(yMax - yMin);

% Initialize the "empty" panorama.
panorama = zeros([height width], 'like', refIm);
panorama_ct = zeros([height width]);


% 
% blender = vision.AlphaBlender('Operation', 'Binary mask', ...
%     'MaskSource', 'Input port');

% blender = vision.AlphaBlender('Operation', 'Blend','OpacitySource','Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits);

% Create the panorama.

for seg = 0:N_seg
    % Initialize the "empty" panorama.
    panorama = zeros([height width], 'like', refIm);
    panorama_ct = zeros([height width]);

    firstLoop = 1;
    for i = 1:length(tforms)%([4 3 1 5 7 0 2 6 8]+1)%1:length(tforms)%

        I = double(imread(['gr_series_v1_' sprintf('%0.3d',(i-1)*(N_seg+2)+seg+1) '.tif']))/255;

        % Transform I into the panorama.
        warpedImage = imwarp(I, tforms{i}, 'OutputView', panoramaView,'FillValues',NaN);
%         panorama = panorama+warpedImage;

        % Generate a binary mask.
        mask = imwarp(ones(size(I,1),size(I,2)), tforms{i}, 'OutputView', panoramaView);
%         panorama_ct = panorama_ct+mask;

        if(firstLoop)
            panorama = warpedImage;
            firstLoop = 0;
        else
            unique_idxs = find(isnan(panorama));
%             overlapped_idxs = find(~isnan(panorama) & ~isnan(warpedImage));
            panorama(unique_idxs) = warpedImage(unique_idxs);
%             panorama(overlapped_idxs) = (warpedImage(overlapped_idxs)+panorama(overlapped_idxs))/2; 
        end

      


    %     % Overlay the warpedImage onto the panorama.
    %     panorama = step(blender, panorama, warpedImage,mask);
        i
    end
      if(seg<1)
            sc = 1;
        else
            sc = 7;
        end
  figure(345235)
    clf
    imshow(panorama*sc)
    pause(0.1)
%     panorama = panorama./panorama_ct;
%     
%     figure(345235)
%     clf
%     imshow(panorama)
%     pause
    
    if(seg==0)
        se2 = panorama;
        dat = zeros([size(panorama) N_seg]);
    else
        dat(:,:,seg) = panorama(:,:);
    end
        
end











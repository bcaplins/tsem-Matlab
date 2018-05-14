function [se2 dat] = regImages(ex)

% load expt object
% obj = load(ex_name);
% ex = obj.obj;

[idxs refidxs] = determineImageReferences(ex.image_relative_positions,ex.pixel_size_nm/1000/1000)

% extract image positions
X = cell2mat(ex.image_relative_positions)*1e3

%  calculate image sizes
width = ex.pixel_size_nm*1024/1e3
height = width*768/1024

% Assume N_seg == number of masks
N_seg = length(ex.mask_filenames);

% TODO
% idxs = [3 1 5 7 0 2 6 8]
% refidxs = [4 4 4 4 3 5 3 5]
idxs = idxs(2:end)-1;
refidxs = refidxs(2:end)-1;


% 
% idxs = [2 1 3]
% refidxs = [0 0 1]

tforms = cell(length(idxs)+1,1);
for i=1:length(idxs)+1
	tforms{i} = affine2d;
end

imageSize = [768 1024];

fnamepre = ex.filename_prefix;


idx_offset = ex.collect_se2;

for i=1:length(idxs)

    
    
    idx = idxs(i);
    refidx = refidxs(i);
    
    dX1 = (X(idx+1,1)/width);
    dY1 = (X(idx+1,2)/height);

    dX2 = (X(refidx+1,1)/width);
    dY2 = (X(refidx+1,2)/height);

    dX = round(1024*(dX2-dX1));
    dY = round(768*(dY2-dY1));

    formatStr = ['%0.' num2str(ex.N_digits) 'd'];
    
    refIm = double(imread([fnamepre sprintf(formatStr ,refidx*(N_seg+idx_offset)) '.tif']))/255;
    im = double(imread([fnamepre sprintf(formatStr ,idx*(N_seg+idx_offset)) '.tif']))/255;
    
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
    
%     tform = tform0;
    
    %     movingRegistered = imregister(im, refIm, 'translation', optimizer, metric,'InitialTransformation',tform0);

    tforms{idx+1}.T = tforms{refidx+1}.T * tform.T
    
    figure(1)
    vieww = imref2d(size(im));
    imshowpair(refIm, imwarp(im,tform,'OutputView', vieww),'diff')

    
%     
    
%     imshowpair(refIm, movingRegistered,'diff')

    


    pause(0.01)


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

        formatStr = ['%0.' num2str(ex.N_digits) 'd'];

        I = double(imread([fnamepre sprintf(formatStr,(i-1)*(N_seg+idx_offset)+seg) '.tif']))/255;

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


end


function [idxs ref_idxs] = determineImageReferences(X,units_per_pixel)
    idxs = [];
    ref_idxs = [];

    rect_area = 1024*units_per_pixel*768*units_per_pixel;
    
    overlaps = zeros(length(X));
    for i=1:length(X)
        for j=1:length(X)
            overlaps(i,j) = rectangleOverlap(X{i}(1:2),X{j}(1:2),1024*units_per_pixel,768*units_per_pixel)/rect_area;
            if(i==j)
                overlaps(i,j) = 0;
            end
        end
    end
    
    overlap_thresh = 0.15;
    
    isVisited = logical(zeros(1,length(X)))
    
    cent = [0 0];
    for i=1:length(X)
        cent = cent+X{i}(1:2);
    end
    cent = cent/length(X);
    
    tmpX = cell2mat(X);
    tmpDist = pdist2(cent,tmpX(:,1:2));
    [dummy tmpIdx] = min(tmpDist);
            
    queuedIdxs = tmpIdx;
    queuedRefIdxs = tmpIdx;
    
    isVisited(queuedIdxs) = logical(1);
    
    loop_ct = 0;
    while ~isempty(queuedIdxs)
        loop_ct = loop_ct+1;
        if(loop_ct>100)
            error('SOMETHING WENT TERRIBLY WRONG')
        end
        
        currIdx = queuedIdxs(1); queuedIdxs(1) = [];
        currRefIdx = queuedRefIdxs(1); queuedRefIdxs(1) = [];
        
        idxs = [idxs currIdx];
        ref_idxs = [ref_idxs currRefIdx];
        
        
        over_idxs = find((overlaps(currIdx,:)>=overlap_thresh) & (~isVisited))
        
        queuedIdxs = [over_idxs queuedIdxs];
        queuedRefIdxs = [repmat(currIdx,1,length(over_idxs)) queuedRefIdxs];
        isVisited(over_idxs) = logical(1);
        
    
    end
    
    
    overlaps

end


function overlap = rectangleOverlap(p1,p2,w,h)

x_overlap = max(0, min(p1(1)+w, p2(1)+w) - max(p1(1), p2(1)));
y_overlap = max(0, min(p1(2)+h, p2(2)+h) - max(p1(2), p2(2)));
overlap = x_overlap * y_overlap;

end






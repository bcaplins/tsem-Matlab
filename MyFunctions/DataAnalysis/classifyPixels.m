function [isGood,isBlocked,isDebris,isVac] = classifyPixels(dat,filt_fun,...
                        isGoodGuess,isGoodStdevThresh,...
                        isBlockedGuess,isBlockedStdevThresh,...
                        groupSizeThreshold)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

% blur_dat = zeros(size(dat));
% for i=1:size(dat,3)
%     blur_dat(:,:,i) = filt_fun(dat(:,:,i));
% end

% Try to find the pixel baselines
% baselines = computeBaselines(blur_dat,0.5);

baselines = sum(dat,3)/2;



[N E] = histcounts(baselines(:),2^8);
C = (E(2:end)+E(1:end-1))/2;


[good_em good_es] = estimateMeanAndStdFromWindow(N,C,isGoodGuess);

[block_em block_es] = estimateMeanAndStdFromWindow(N,C,isBlockedGuess);

good_lims = [good_em-isGoodStdevThresh(1)*good_es good_em+isGoodStdevThresh(2)*good_es];
isGood = (baselines<good_lims(2) & baselines>=good_lims(1));

block_lims = [block_em-isBlockedStdevThresh(1)*block_es block_em+isBlockedStdevThresh(2)*block_es];
isBlocked = (baselines<block_lims(2) & baselines>=block_lims(1));

debris_lims = [good_lims(2) inf];
isDebris = (baselines<debris_lims(2) & baselines>=debris_lims(1));

vac_lims = [block_lims(2) good_lims(1)];
isVac = (baselines<vac_lims(2) & baselines>=vac_lims(1));



figure(1)
clf


idxs = find(C>=block_lims(1) & C<block_lims(2));
bar(C(idxs),N(idxs))
hold on

idxs = find(C>=vac_lims(1) & C<vac_lims(2));
bar(C(idxs),N(idxs))

idxs = find(C>=good_lims(1) & C<good_lims(2));
bar(C(idxs),N(idxs))

idxs = find(C>=debris_lims(1) & C<debris_lims(2));
bar(C(idxs),N(idxs))

legend('block','vac','good','debris')

figure(2)
clf
subplot(2,2,1)
imshow(isVac)
title('vac')
subplot(2,2,2)
imshow(isDebris)
title('debris')
subplot(2,2,3)
imshow(isGood)
title('good')
subplot(2,2,4)
imshow(isBlocked)
title('blocked')

% Close the ribs is possible
isGood = 1-bwmorph(1-isGood,'close');

% remove pixel groups of 5 or less
isGood = 1-bwareaopen(1-isGood,groupSizeThreshold,8);

isGood = 1-imdilate(1-isGood,strel('square',3));
% isGood = 1-imdilate(1-isGood,strel('diamond',2));

isGood = logical(isGood);


end


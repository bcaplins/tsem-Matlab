function baselines = computeMaxes(dat,numPix)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

tmp = reshape(dat,[size(dat,1)*size(dat,2) size(dat,3)]);
tmp_sorted = sort(tmp,2);
baselines = reshape(mean(tmp_sorted(:,(end-numPix+1):end),2),[size(dat,1) size(dat,2)]);


end


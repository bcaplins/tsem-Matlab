function baselines = computeBaselines(dat,meth)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% meth == 0->1 then assume fraction of points  (horiz line)
% meth == greater then 1 then take round(meth) points


if nargin<2
    idxs = round(0.3*size(dat,3)):round(0.7*size(dat,3));
else
    if(meth>0 && meth<1)
        idxs = 1:ceil(meth*size(dat,3));
    elseif(meth>=1)
        idxs = 1:meth;
    else
        error('ERROR')
    end
end

tmp = reshape(dat,[size(dat,1)*size(dat,2) size(dat,3)]);
tmp_sorted = sort(tmp,2);
baselines = reshape(mean(tmp_sorted(:,idxs),2),[size(dat,1) size(dat,2)]);


end


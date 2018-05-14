function [orient_map,amp_map] = createOrientationAmplitudeMaps(dat,isGood,spSegs)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here


% Mask off the bad data and determine averages
for i=1:size(dat,3)
    tmp = dat(:,:,i);
    tmp(~isGood) = NaN;
    dat(:,:,i) = tmp;
end

L = double(spSegs+1);

idx = label2idx(L);

numLabels = numel(idx);
numRows = size(dat,1);
numCols = size(dat,2);
numDims = size(dat,3);

numPix = numRows*numCols;

mean_values = zeros(numLabels,numDims);

for labelVal = 1:numLabels
    for id = 1:numDims
        chanIdx = idx{labelVal} + (id-1)*numPix;
        mean_values(labelVal,id) = mean(dat(chanIdx),'omitnan');
        if(~isfinite(mean_values(labelVal,id)))
            mean_values(labelVal,id) = 0;
        end
    end
end    


orient_vals = zeros(numLabels);
amp_vals = zeros(numLabels);
for i=1:numLabels
    x = ((1:20)*3-3)';
    y = mean_values(i,:)';

    if(mean(y)==0)
        continue
    end
    
    [sy si] = max(y);
    [sb dummy] = min(y);
    p0 = [sy-sb x(si) 2 sb 2e-4];
    
    fun = @(a,b,c,d,e,x) a*wrappedGauss(x*6*pi/180,b*6*pi/180,c*6*pi/180)+d*x+e;
    
    ft = fittype(fun,'independent','x');
    f = fit(x,y,ft,'StartPoint',p0);
%     plot( f, x, y)

    orient_vals(i) = f.b;
    amp_vals(i) = f.a;
    
%     [p_fit,resnorm,residual,exitflag,output] = lsqcurvefit(fun,p0,x,y)
    

    

i
end

orient_map = zeros(size(dat,1),size(dat,2));
amp_map = zeros(size(dat,1),size(dat,2));
for labelVal = 1:numLabels
    chanIdx = idx{labelVal};
    orient_map(chanIdx) = orient_vals(labelVal);
    amp_map(chanIdx) = amp_vals(labelVal);
end

end

    
%     y = mean_values(i,:)';
%     [sy si] = max(y);
%     [sb dummy] = min(y);
%     startPoints = [sy-sb x(si) 2 sb 2e-4];
%     gaussEqn = 'a*exp(-(((x-b)/(sqrt(2)*c))^2))+d*x+e';
%     f1 = fit(x,y,gaussEqn,'Start', startPoints);
%     
%     subplot(1,2,1)
%     plot(x,y,'o--',x,f1(x),'r-')
% %         ylim([0.03 0.12])
%     hold on
%     subplot(1,2,2)
%     hold on
%     plot(f1.b*[1 1],[0 max(N)],'k')
%     ci = confint(f1);
%     plot(ci(1,2)*[1 1],[0 max(N)],'k--')
%     plot(ci(2,2)*[1 1],[0 max(N)],'k--')
%     xlim([0 60])
%     fittedAngs = [fittedAngs f1.b];
%     f1



function [cts totalcts] = integrateOverTheta(angs,thetas)
totalcts = length(angs);    
cts = 0;
mi = min(thetas);
ma = max(thetas);
for i=1:length(angs)
    if(angs(i)>= mi && angs(i)<=ma)
        cts=cts+1;
    end
end


        
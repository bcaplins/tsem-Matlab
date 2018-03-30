% Alpha = 2.53*AD/(WD+9)
% 
% Alpha = beam convergence semi-angle (radians)
% AD = beam condenser aperture diameter (mm)
% WD = working distance (mm)


alpha = @(ap,wd) 2.53*ap./(wd+9);


spatial_res = 0.03;

aps = [10 20 30 60 120 300]./1000;
min_res = zeros(size(aps));
min_CL = zeros(size(aps));
min_WD = zeros(size(aps));


for idx = 1:length(aps)
    
    ap = aps(idx);

    WDsamp = linspace(3,15,2^7);
    CL = linspace(5,22,2^7);

    [WDs CLs] = meshgrid(WDsamp,CL);

    al = alpha(ap,WDs);

    delta = atan(spatial_res./CLs);

    res = max(delta,al);

    for i=1:numel(WDs)
        WD2 = CLs(i)+WDs(i);
        if(WD2>25 || WD2<16)
            res(i) = NaN;
        end
    end


    [y i] = min(res(:));
    min_res(idx) =  y;
    min_WD(idx) =  WDs(i);
    min_CL(idx) =  CLs(i);
    
    figure(523)
    % contourf(CLs,WDs,1000*res,30,'EdgeColor','none')
    % contour(CLs,WDs,1000*res,30)
    contourf(CLs,WDs,1000*res,[0:0.25:5])
    caxis([ 0 5])


    xlabel('CL')
    ylabel('WD')
    colorbar
    pause
    
end

[min_res
    min_WD
    min_CL]'



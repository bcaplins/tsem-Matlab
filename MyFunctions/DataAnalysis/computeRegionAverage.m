function y = computeRegionAverage(disp_dat,calc_dat,isGood)
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
    Cdat = convertHyperspectralImageToHSVimage(disp_dat,1);
    figure(102),clf,imshow(Cdat)
    
    mask = roipoly;
    
    y = zeros(1,size(calc_dat,3));
    for i=1:size(calc_dat,3)
        tmp = calc_dat(:,:,i);
        y(i) = mean(tmp(isGood & mask));
    end


end


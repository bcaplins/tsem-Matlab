function hsv_dat = convertHyperspectralImageToHSVimage(dat,doBaselineSubtraction)
            
    nd = size(dat,3);

    cv = hsv(nd);
    
%     cv = perceptColormap(nd);
    if(doBaselineSubtraction)
        dat = dat-computeBaselines(dat);
    end
    
    hsv_dat = reshape(dat,[size(dat,1)*size(dat,2) size(dat,3)])*cv;
    mean_norm = mean(vecnorm(hsv_dat,2,2));
    hsv_dat = hsv_dat/mean_norm;

    hsv_dat = reshape(hsv_dat,[size(dat,1) size(dat,2) 3]);

end


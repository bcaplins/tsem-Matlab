function hsv_dat = convertHyperspectralImageToHSVimage(dat,doBaselineSubtraction)
            
    nd = size(dat,3);

    cv = hsv(nd);
    
%     cv = perceptColormap(nd);
    
    hsv_dat = zeros([size(dat,1) size(dat,2) 3]);
    
    sumtot = 0;
    for i=1:size(dat,1)
        for j=1:size(dat,2)
            y = dat(i,j,:);
            tmp = sort(y);
            if(doBaselineSubtraction)
                bl = mean(tmp(1:ceil(nd*.5)));
            else 
                bl = 0;
            end

            y = y(:)-bl;

            tmp = sum(y.*cv,1);
            hsv_dat(i,j,:) = tmp;
            sumtot = sumtot+norm(tmp);
        end
    end
    sc = sumtot./(size(dat,1)*size(dat,2));
    hsv_dat = hsv_dat/sc;

end


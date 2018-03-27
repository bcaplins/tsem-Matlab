function [est_mean, est_std] = estimateMeanAndStdFromPercentile(dat)

    sdat = sort(dat);
    
    l = (1-0.6827)/2;
    r = 1-l;
    
    lidx = ceil(length(dat)*l);
    ridx = floor(length(dat)*r);
    
    est_std = (sdat(ridx)-sdat(lidx))/2;
    est_mean = sdat(round(length(dat)/2));
   
    N_std = 3;
    
    ndat = dat((dat>=(est_mean-N_std*est_std)) & (dat<=(est_mean+N_std*est_std)));
    sndat = sort(ndat);
   
    lidx = ceil(length(ndat)*l);
    ridx = floor(length(ndat)*r);
    
    est_std = (sndat(ridx)-sndat(lidx))/2;
    est_mean = sndat(round(length(ndat)/2));
   
    
end


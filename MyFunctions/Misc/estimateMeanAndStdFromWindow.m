function [est_mean, est_std] = estimateMeanAndStdFromWindow(N,Cs,lims)

    idxs = find(Cs>=min(lims) & Cs<=max(lims));
    
    
    
    [max_val max_idx] = max(N(idxs));
    N = N/max_val;
    
    real_max_idx = idxs(max_idx);
    
    est_mean = Cs(real_max_idx);
    
    right_hm = nan;
    for i=real_max_idx:length(Cs)
        if(N(i)<0.5)
            right_hm = interp1(N((i-1):i),Cs((i-1):i),0.5);
            break;
        end
    end

    left_hm = nan;
    for i=real_max_idx:-1:1
        if(N(i)<0.5)
            left_hm = interp1(N(i:(i+1)),Cs(i:(i+1)),0.5);
            break;
        end
    end
    fwhm = right_hm-left_hm;
    est_std = fwhm/(2*sqrt(2*log(2)));

% 
%     local_window = [est_mean-2*est_std est_mean+2*est_std];
%        
%     local_dat = dat(dat>=local_window(1) & dat<=local_window(2));
%     
%     
%     
%     
%     sdat = sort(local_dat);
%     
%     l = (1-0.6827)/2;
%     r = 1-l;
%     
%     lidx = ceil(length(local_dat)*l);
%     ridx = floor(length(local_dat)*r);
%     
%     est_std = (sdat(ridx)-sdat(lidx))/2;
%     est_mean = sdat(round(length(local_dat)/2));
%    


%     sdat = sort(dat);
%     
%     l = (1-0.6827)/2;
%     r = 1-l;
%     
%     lidx = ceil(length(dat)*l);
%     ridx = floor(length(dat)*r);
%     
%     est_std = (sdat(ridx)-sdat(lidx))/2;
%     est_mean = sdat(round(length(dat)/2));
%    
%     N_std = 3;
%     
%     ndat = dat((dat>=(est_mean-N_std*est_std)) & (dat<=(est_mean+N_std*est_std)));
%     sndat = sort(ndat);
%    
%     lidx = ceil(length(ndat)*l);
%     ridx = floor(length(ndat)*r);
%     
%     est_std = (sndat(ridx)-sndat(lidx))/2;
%     est_mean = sndat(round(length(ndat)/2));
   
    
end


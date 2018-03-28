function hsv_dat = convertAngleDataToHSVimage(angs,amps,max_ang)            
    cv = hsv(max_ang);
    hsv_dat = zeros([size(angs,1) size(angs,2) 3]);
    if(sum(angs(:)==0)>0)
        angs = angs+1;
    end
    
    
    
%     angs(angs==0) = max_ang;
    for i=1:size(angs,1)
        for j=1:size(angs,2)
            hsv_dat(i,j,:) = amps(i,j)*cv(angs(i,j),:);
        end
    end
%     hsv_dat = hsv_dat./mean(amps(:))/2;
end


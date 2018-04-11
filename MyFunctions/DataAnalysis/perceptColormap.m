function cm = perceptColormap( num)
%PERCEPTCOLORMAP Summary of this function goes here
%   Detailed explanation goes here
    [map, descriptorname, description] = colorcet('C2');
    map(end+1,:) = map(1,:);
    
    qidxs = 1:num;
    qidxs = qidxs/(num+1);
    
    idxs = 1:length(map);
    idxs = idxs/length(map);
    
    A = interp1(idxs,map(:,1),qidxs);
    B = interp1(idxs,map(:,2),qidxs);
    C = interp1(idxs,map(:,3),qidxs);

    
    cm = [A' B' C'];

end


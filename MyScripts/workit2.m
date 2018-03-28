% clear all
% 
% % Load data

% pre = 'graph_series_12spot_v1_'
% pre = 'graph_series_v1_'
% pre = '..\20180326\graph_series_v2_'
% 
% N_dig = 2;
N_seg = 20;
% roi_i = 1:640;
% roi_j = 1:1024;


roi_i = 31:1630;
roi_j = 19:2354;

% se2 = se2(roi_i,roi_j);
% dat = dat(roi_i,roi_j,:);
% 

% [se2 dat] = loadRotDFStack(pre,N_dig,N_seg,roi_i,roi_j,8,0);



% makeBigImage;
N_tot = 3;
N_block = 4;

% block average if desired

se2_red = blockAverageData(se2,N_block);
red_dat = blockAverageData(dat,N_block);

N_levels = N_tot-log2(N_block);

[red_dat dat_ims dat_rims] = recursiveColor(red_dat,N_levels);
[se2_red se2_ims se2_rims] = recursiveColor(se2_red,N_levels);







% dat = dat_rims{end};
% 
% for i=1:N_seg
%     figure(432121)
%     clf
%     imshow(dat(:,:,i),'InitialMagnification',1000)
%     pause
% end
% 
% for i=1:size(dat,1)
%     for j=1:size(dat,2)
%         figure(432122)
%         clf
%         plot(reshape(dat(i,j,:),[N_seg 1]))
%         pause
%     end
% end

% for i=1:size(red_dat,1)
%     for j=1:size(red_dat,2)
%         figure(432122)
%         clf
%         plot(reshape(red_dat(i,j,:),[N_seg 1]))
%         pause
%     end
% end


% figure(432122)
% clf
% d = reshape(permute(dat,[3 1 2]),[N_seg size(dat,1)*size(dat,2)]);
% dd = std(d,0,2);
% dd = dd-min(dd);
% dd = dd./max(dd);
% plot(dd,'-o')
% hold on
% dd = mean(d,2);
% dd = dd-min(dd);
% dd = dd./max(dd);
% plot(dd,'-o')
% 
% 
% 
% figure(432122)
% clf
% d = reshape(permute(dat,[3 1 2]),[N_seg size(dat,1)*size(dat,2)]);
% cv = cov(d');
% size(cv)
% 
% clf
% contourf(cv)
% axis square



% return


% [se2 dat] = loadRotDFStack(pre,N_dig,N_seg,roi_i,roi_j,8);



% delare results variables
sz = size(red_dat);
means = zeros(sz(1),sz(2));
baselines = zeros(sz(1),sz(2));
maxang = zeros(sz(1),sz(2));
maxval = zeros(sz(1),sz(2));

% setup IRFS
N_REFS = 60;
d = 6;

x0s = 0:60/N_REFS:60;
x0s = x0s(1:end-1);
[xqs refs] = beamProfileIRF(x0s,N_seg,d);


% Try to find the angle of the diffraction pattern... FAST
for i=1:size(red_dat,1)
    for j=1:size(red_dat,2)
        y = red_dat(i,j,:);
        tmp = sort(y);
        
        means(i,j) = mean(y);
        baselines(i,j) = mean(tmp(1:ceil(N_seg*.5)));
        
        y = y(:)';
        metr = sum(y.*refs,2);
        
        [dum idx] = max(metr);
        maxang(i,j) = x0s(idx);
        maxval(i,j) = dum;
        
    end
    [i,j]
end


% Determine ribs
[em es] = estimateMeanAndStdFromPercentile(baselines(:));

N_std_low = 2;
N_std_high = 5;

figure(1231)
clf
histogram(baselines(:),100)
hold on
plot(em*[1 1]+N_std_high*es,[0 1000],'k')
plot(em*[1 1],[0 9000],'k')
plot(em*[1 1]-N_std_low*es,[0 1000],'k')

isGood = (baselines<=(em+N_std_high*es) & means>=(em-N_std_low*es));



% Clean up rib structure
figure(321312)
imshow(isGood)

% Close the ribs is possible
isGood = 1-bwmorph(1-isGood,'close');

% remove pixel groups of 5 or less
isGood = 1-bwareaopen(1-isGood,4,8);

% isGood = 1-imdilate(1-isGood,strel('square',3));
isGood = 1-imdilate(1-isGood,strel('diamond',1));


% Generate an image in HSV colorspace (cyclic)
Cmaxang = zeros([size(maxang) 3]);
cm = hsv(60);
for i=1:size(maxang,1)
    for j=1:size(maxang,2)
        if(isGood(i,j))
            Cmaxang(i,j,:) = cm(maxang(i,j)+1,:);
        else
            Cmaxang(i,j,:) = 0;
        end
    end
end

figure(3245324)
imshow(Cmaxang)

% 
% 
%     d = reshape(permute(Cmaxang,[3 1 2]),[3 size(Cmaxang,1)*size(Cmaxang,2)])';
% 
%     [modes, mode_pr, labels] = findModes(d, 10000, 0.5);
% 
%     figure(2312)
%     imshow(reshape(labels,size(Cmaxang,1),size(Cmaxang,2))/max(labels),'InitialMagnification', 1000)
%     
%     size(modes)

    
%     return
    
figure(1)
imshow(red_dat(:,:,4))



figure(324254324)
imshow(maxang/60)

figure(324254325)
% 
% ModeFilterFunction = @(x) mode(x(:));
% modeImage = nlfilter(maxang/60, [3 3], ModeFilterFunction);

f = image(medfilt2(maxang,[5 5]))
% f = image(maxang)
f.AlphaData = isGood;
colormap(hsv)
caxis([0 60])
f.CDataMapping = 'scaled'




figure(3245325)
imshowpair(se2,blockExpandData(Cmaxang,N_block),'montage')



figure(41424)
clf
hdat = maxang;
hdat(isGood~=1) = [];
histogram(hdat,N_REFS)
xlabel('angle of graphene lattice')
ylabel('# of pixels')





% 
% ddd = dat;
% figure(432122)
% clf
% d = reshape(permute(ddd,[3 1 2]),[N_seg size(ddd,1)*size(ddd,2)]);
% cv = cov(d')-diag(var(d'));
% size(cv)
% 
% clf
% f = surf(cv)
% f.EdgeColor = 'none'
% axis square
% view([0 90])
% axis tight




return


hs = 5;
hr = 1*.1;
w = hs*3;

fDat = blockExpandData( bfilter2(Cmaxang,w,[hs hr]),N_block);
figure(3245326)
imshowpair(blockExpandData(Cmaxang,N_block),fDat,'montage')





hs = 3;
hr = 3/60;
w = hs*3;

fDat = bfilter2(maxang/60,w,[hs hr]);
for i=1:4
    fDat = bfilter2(fDat,w,[hs hr]);
    figure(3245324)
    f  = image(fDat*60)
    colormap(hsv)
    caxis([0 60])
    f.CDataMapping = 'scaled'
    f.AlphaData = isGood;
    pause()
end





figure(41423)
clf
hdat = fDat*60;
hdat(isGood~=1) = [];
histogram(hdat,N_REFS)
xlabel('angle of graphene lattice')
ylabel('# of pixels')





return



fulldat = reshape(red_dat,size(red_dat,1)*size(red_dat,2),N_seg);
fulldat(isGood(:)~=1,:) = NaN;

N_CLUST = 3;
[cluster_idx, cluster_center] = kmeans(fulldat,N_CLUST,'distance','sqeuclid', ...
                                      'Replicates',16);


pixel_labels = reshape(cluster_idx,size(red_dat,1),size(red_dat,2),1);
% pixel_labels = reshape(cluster_idx,size(maxang,1),size(maxang,2));





figure(52345324)
imshow(pixel_labels,[1 N_CLUST],'InitialMagnification',50*N_block)
title('image labeled by cluster index');
% pause

figure(241431)
clf
plot(circshift(cluster_center,5,2)')



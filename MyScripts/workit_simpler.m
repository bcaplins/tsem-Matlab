% clear all
close all

figure(1)
clf


% pre = 'graph_series_12spot_v1_'
% pre = 'graph_series_v1_'
% pre = '..\20180321\graph_series_v1_'
% pre = '..\20180326\graph_series_v2_'
% post = '.tif'

% clear fns;


N_seg = 20;
% roi_i = 1:768;
% roi_j = 1:1024;
%  N_dig = 3;
roi_i = 1:size(se2,1);
roi_j = 1:size(se2,2);


for i=1:size(dat,3)
    D = reshape(dat(:,:,i),[size(se2,1) size(se2,2) ,1]);
    figure(2312312)
    clf
    imshow(D*8)
    pause()
end

dat(isnan(dat)) = 0;

Cdat = convertHyperspectralImageToHSVimage(dat,1);

figure(314212)
clf
imshow(Cdat)



x = (60/N_seg)*([1:N_seg]'-1);


% [se2 dat] = loadRotDFStack(pre,N_dig,N_seg,roi_i,roi_j,8,22);

se2_red = se2;
red_dat = dat;


sigma = @(fwhm) fwhm/(2*sqrt(2*log(2)));
blur_dat = imgaussfilt3(red_dat,[sigma(6) sigma(6) sigma(1)]);

red_dat = blur_dat ;

% delare results variables
sz = size(red_dat);
means = zeros(sz(1),sz(2));
baselines = zeros(sz(1),sz(2));
maxang = zeros(sz(1),sz(2));
% maxval = zeros(sz(1),sz(2));
% means_scat = zeros(sz(1),sz(2));

% % setup IRFS
% N_REFS = 60;
% d = 6;
% 
% x0s = 0:60/N_REFS:60;
% x0s = x0s(1:end-1);
% [xqs refs] = beamProfileIRF(x0s,N_seg,d);


% Try to find the angle of the diffraction pattern... FAST
for i=1:size(red_dat,1)
    for j=1:size(red_dat,2)
        y = red_dat(i,j,:);
        tmp = sort(y);
        
        means(i,j) = mean(y);
        baselines(i,j) = mean(tmp(1:ceil(N_seg*.33)));
        
        y = y(:)'-baselines(i,j);
%         metr = sum(y.*refs,2);
        
%         means_scat(i,j) = mean(y);
            
        [dum idx] = max(y);
        maxang(i,j) = x(idx);
%         maxval(i,j) = dum;
        
    end
    [i,j]
end


% Determine ribs
[em es] = estimateMeanAndStdFromPercentile(baselines(:));

N_std_low = 3;
N_std_high = 5;

subplot(2,3,1)
[N E] = histcounts(baselines(:),100);
bar((E(2:end)+E(1:end-1))/2,N)
hold on
mxh = max(N);
plot(em*[1 1]+N_std_high*es,[0 mxh],'k')
plot(em*[1 1],[0 mxh],'k')
plot(em*[1 1]-N_std_low*es,[0 mxh],'k')

isGood = (baselines<=(em+N_std_high*es) & means>=(em-N_std_low*es));

% Clean up rib structure
subplot(2,3,2)
imshow(isGood)

% Close the ribs is possible
isGood = 1-bwmorph(1-isGood,'close');

% remove pixel groups of 5 or less
isGood = 1-bwareaopen(1-isGood,4,8);

% isGood = 1-imdilate(1-isGood,strel('square',3));
isGood = 1-imdilate(1-isGood,strel('diamond',2));


subplot(2,3,3)
hdat = maxang;
hdat(isGood~=1) = [];
[N E] = histcounts(hdat,N_seg);
bar((E(1:end-1)+E(2:end))/2,N)
xlabel('angle of graphene lattice')
ylabel('# of pixels')




% Generate an image in HSV colorspace (cyclic)
Cmaxang = convertAngleDataToHSVimage(maxang,isGood,60);
subplot(2,3,[4 5])

figure
imshowpair(Cmaxang,se2,'montage')
colormap(hsv)
caxis([0 60])
colorbar



gX = ginput
R = 5;

for i=1:size(gX,1)
    h = gcf;
    hold on
    plot_circle(gX(i,:),R,h)
end
figure(h)

fittedAngs = [];
for i=1:size(gX,1)
    is = -R:R;
    js = -R:R;
    [Is Js] = meshgrid(is,js);
    
    idxs = find((Is.^2+Js.^2)<=R.^2);
      
    Is = Is(idxs)+round(gX(i,2));
    Js = Js(idxs)+round(gX(i,1));
    
    avgDat = zeros(N_seg,1);
    for idx=1:length(Is)
        tmp = dat(Is(idx),Js(idx),:);
%         pause
        avgDat = avgDat + tmp(:);
    end
    avgDat =  avgDat/length(Is);
    
    
    y = avgDat;
    [sy si] = max(avgDat);
    [sb dummy] = min(avgDat);
    startPoints = [sy-sb x(si) 2 sb ];
    gaussEqn = 'a*exp(-(((x-b)/(sqrt(2)*c))^2))+d';
    f1 = fit(x,y,gaussEqn,'Start', startPoints);
    
    subplot(2,3,6)
    plot(x,y,'o--',x,f1(x),'r-')
        ylim([0.03 0.12])
    hold on
    subplot(2,3,3)
    hold on
    plot(f1.b*[1 1],[0 max(N)],'k')
    ci = confint(f1);
    plot(ci(1,2)*[1 1],[0 max(N)],'k--')
    plot(ci(2,2)*[1 1],[0 max(N)],'k--')
    fittedAngs = [fittedAngs f1.b];
    pause
end




fittedAngs'






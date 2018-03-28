clear all
% close all

figure(1)
clf


% pre = 'graph_series_12spot_v1_'
% pre = 'graph_series_v1_'
pre = '..\20180321\graph_series_v1_'
% pre = '..\20180326\graph_series_v2_'
post = '.tif'

clear fns;


N_seg = 20;
roi_i = 1:640;
roi_j = 1:1024;
N_dig = 2;

[se2 dat] = loadRotDFStack(pre,N_dig,N_seg,roi_i,roi_j,8,0);

se2_red = se2;
red_dat = dat;


sigma = @(fwhm) fwhm/(2*sqrt(2*log(2)));
blur_dat = imgaussfilt(red_dat,sigma(6));

red_dat = blur_dat ;

% delare results variables
sz = size(red_dat);
means = zeros(sz(1),sz(2));
baselines = zeros(sz(1),sz(2));
maxang = zeros(sz(1),sz(2));
maxval = zeros(sz(1),sz(2));
means_scat = zeros(sz(1),sz(2));

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
        baselines(i,j) = mean(tmp(1:ceil(N_seg*.33)));
        
        y = y(:)'-baselines(i,j);
        metr = sum(y.*refs,2);
        
        means_scat(i,j) = mean(y);
            
        [dum idx] = max(metr);
        maxang(i,j) = x0s(idx);
        maxval(i,j) = dum;
        
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
histogram(hdat,N_REFS)
xlabel('angle of graphene lattice')
ylabel('# of pixels')




% Generate an image in HSV colorspace (cyclic)
Cmaxang = convertAngleDataToHSVimage(maxang,isGood,60);
subplot(2,3,[4 5 6])


imshowpair(se2,Cmaxang,'montage')
colormap(hsv)
caxis([0 60])
colorbar



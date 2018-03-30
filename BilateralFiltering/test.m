% close all

% fn = 'E:\Caplins\20180322\graph_series_12spot_v1_00.tif';
% 
% I = imread(fn);
% I = I(1:512,1:512);

% I = maxang;

I = Cmaxang;

I(repmat(~isGood,[1 1 3])) = 0;




w = 12;
hs = 4;
hr = 2*.1;

S = bfilter2(I,w,[hs hr]);
% S = bfilter2(S,w,[hs hr]);
% S = bfilter2(S,w,[hs hr]);


figure(431)
imshow(I,'InitialMagnification',250)
% imshowpair(I,S,'Montage')
figure(432)
imshow(S,'InitialMagnification',250)

figure(434)

rot = ImageMapping.clockwiseRotationMatrixFunction;

v1 = [1 0]';
v2 = rot(120*pi/180)*v1;
v3 = rot(120*pi/180)*v2;

sangs = zeros([size(S,1) size(S,2)]);

for i=1:size(S,1)
    for j=1:size(S,2)
        tmp = S(i,j,1)*v1+S(i,j,2)*v2+S(i,j,3)*v3;
        sangs(i,j) = (1/6)*(pi+atan2(tmp(2),tmp(1)))*180/pi;
    end
end
sangs(~isGood(:)) = inf;
sangs = medfilt2(sangs,[3 3]);

figure(132413)
f = image(mod(sangs+30,60))
f.AlphaData = isGood;
caxis([0 60])
colormap(hsv)
% f.CDataMapping = 'scaled';
colorbar()
axis image
ax = gca
ax.Visible = 'off'


figure(132)
histogram(sangs,60)





% 
% idfun = @(X) X;
% % 
% % gray = 0;
% % if(size(I,3)==1)
% % gray = 1;
% % I = repmat(I,[1 1 3]);
% % end
%   tic
%   [fimg labels modes regsize grad conf] = edison_wrapper(I,@RGB2Luv,...
%       'SpatialBandWidth',hs,'RangeBandWidth',hr,...
%       'MinimumRegionArea',M,'SpeedUp',2,'Steps',1);
%   toc
%   S = Luv2RGB(fimg);
% % 
% %   if(gray == 1)
% %     S = rgb2gray(S);
% %   end
% %   
%   
%   figure(431)
%   image(S)
%   imshowpair(I,S,'Montage')
%   
  
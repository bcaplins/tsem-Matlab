% close all

% fn = 'E:\Caplins\20180322\graph_series_12spot_v1_00.tif';
% 
% I = imread(fn);
% I = I(1:512,1:512);

I = maxang;


size(I)
max(I(:))
min(I(:))

I = im2uint8(Cmaxang);


hs =5;
hr = 100;
M = 1;



idfun = @(X) X;
% 
% gray = 0;
% if(size(I,3)==1)
% gray = 1;
% I = repmat(I,[1 1 3]);
% end
  tic
  [fimg labels modes regsize grad conf] = edison_wrapper(I,@RGB2Luv,...
      'SpatialBandWidth',hs,'RangeBandWidth',hr,...
      'MinimumRegionArea',M,'SpeedUp',2,'Steps',1);
  toc
  S = Luv2RGB(fimg);
% 
%   if(gray == 1)
%     S = rgb2gray(S);
%   end
%   
  
  figure(431)
  image(S)
  imshowpair(I,S,'Montage')
  
  
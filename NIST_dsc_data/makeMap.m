


[thetas zero_scat_prob eff_dsc] = computeMultipleScatteringDistribution('Si',30,10e-9)


x = linspace(-1.5,1.5,2^10);
y = linspace(-1.5,1.5,2^10);


[X Y] = meshgrid(x,y);

R = sqrt(X.^2+Y.^2);
T = atan(R./10);

I = interp1(thetas,eff_dsc,T(:),'linear');
I = reshape(I,size(R));

beam_conv = 3e-3;

max_pre = max(max(I));

ss = sum(sum(I));

I = (1-zero_scat_prob)*I./ss;

num_pix = numel(find(T<=beam_conv));

val = zero_scat_prob/num_pix;


I(T<=beam_conv) = I(T<=beam_conv)+val;

I = ss*I./max_pre;
I = I.^(1/3);



figure(1)
clf
ax = surf(X,Y,I)

colormap(gray)

ax.LineStyle = 'none'


caxis([0 1])
view([0 90])

axis square


% 
% 
% 
% 
% wd = 'C:\Users\bwc\Documents\MATLAB\data\20171206\AmorphousSi\';
% X = load('C:\Users\bwc\Documents\MATLAB\data\20171130\cal\IMAGEMAPPING.mat')
% imgMap = X.img_mapping;
% 
% fn = 'C:\Users\bwc\Documents\MATLAB\data\20171206\AmorphousSi\15nm_amor_Si_foc_YAG_5000ms.png'
% bg = 'C:\Users\bwc\Documents\MATLAB\data\20171206\AmorphousSi\5000ms_bg.png'










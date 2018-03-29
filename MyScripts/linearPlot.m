
% 
% diam = [0 10 20 30 60 120]/1000
% 
% farad = -[-0.1 -30 -122.5 -267.5 -1100 -4360]/1000
% % pmt = [5 6.731 10.993 17.636 53.212 185.078]
% pmt = [5 6.512 10.419 16.542 51.151 186.888]

diam = [0 10 20 30]/1000
farad = -[-0.1 -30 -122.5 -267.5]/1000
pmt = [5.118 25.028 84.835 179.299]


diam = diam(2:end)-diam(1);
farad = farad(2:end)-farad(1);
pmt = pmt(2:end)-pmt(1);


figure(1)
clf
plot(diam.^2,farad,'-o')


figure(2)
clf
plot(farad,pmt./max(pmt),'-o')

[p s] = polyfit(farad(1:3),pmt(1:3),1)

hold on
plot([0 farad],polyval(p,[0 farad])./max(pmt))
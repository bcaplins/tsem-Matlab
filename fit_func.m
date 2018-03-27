function [x y] = fit_func(x0,N_seg,d)

xs = 0:60/N_seg:60;


xq = linspace(0,60, 360);
dxq = xq(2)-xq(1);
yq = linspace(-d/2,d/2,512);
dyq = yq(2)-yq(1);
[Xq Yq] = meshgrid(xq,yq);
cir = (sqrt((Xq-30).^2+Yq.^2)<=(d/2))/(pi*d*d/4);
cir_pro = sum(cir,1);

delx = 30-x0;
delx_idx = round(delx./dxq);

cir_pro = circshift(cir_pro,-delx_idx);
y = zeros(1,N_seg);
for i=1:length(xs)-1
    y(i) = sum(cir_pro(xq>=xs(i) & xq<xs(i+1)));
end
y = y*dxq*dyq;

x = xs(1:end-1);










end
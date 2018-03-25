function [x y] = fit_func(x0,N_seg,d)
% xs = 0:60/N_seg:60;
% 
% [dummy idx] = min(abs(xs(1:end-1)-x0));
% shift_idx = idx-floor(length(xs)/2)
% % if(shift_idx>(length(xs)-1))
% %     shift_idx = mod(idx+floor(length(xs)/2),length(xs))
% %     shift_x = -xs(shift_idx+1);
% % else
% %     shift_x = xs(shift_idx);
% % end
% if(shift_idx == 0)
%     shift_x = 0;
% elseif(shift_idx>0)
%     shift_x = -xs(shift_idx);
% elseif(shift_idx<0)
%     shift_x = xs(N_seg+shift_idx);
% end
%     
% xs = xs-shift_x;
%     
% [min(xs) max(xs)]
% 
% f = @(x,y) (sqrt((x-x0).^2+y.^2)<=(d/2))/(pi*d*d/4);
% 
% 
% y = zeros(1,length(xs)-1);
% for i=1:N_seg
%     y(i) = integral2(f,xs(i),xs(i+1),-d/2,d/2);
% end
% % x = xs(1:end-1);
% % x = circshift(x,-shift_idx);
% x = xs(1:end-1)+shift_x;
% y = circshift(y,shift_idx);
% 
% %     xs = xs(1:end-1);
%     
%     
% 


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
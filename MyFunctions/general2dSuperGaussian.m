function val = general2dSuperGaussian( X,Y,p)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

x0 = p(1);
y0 = p(2);

    sx = p(3);
sy = p(4);

amp = p(5);
off = p(6);
ang = p(7);
n = p(8);

a = (cos(ang)^2)/(2*sx*sx)+(sin(ang)^2)/(2*sy*sy);
b = -sin(2*ang)/(4*sx*sx)+sin(2*ang)/(4*sy*sy);
c = (sin(ang)^2)/(2*sx*sx)+(cos(ang)^2)/(2*sy*sy);

val = off+amp*exp(-(a*(X-x0).^2 +2*b*(X-x0).*(Y-y0)+c*(Y-y0).^2).^n);


end


function [X Y] = make_circle(p0, sc)

th = linspace(0,2*pi,100);

X = cos(th);
Y = sin(th);

X = X*sc + p0(1);
Y = Y*sc + p0(2);

return


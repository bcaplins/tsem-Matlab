function [X Y] = genCircle(p0,r)

    
thetas = linspace(0, 2*pi, 128);

X = r*cos(thetas)+p0(1);
Y = r*sin(thetas)+p0(2);

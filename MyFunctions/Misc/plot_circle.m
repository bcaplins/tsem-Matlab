function h = plot_circle(p0, sc, h)

[X Y] = make_circle(p0,sc);

if nargin<3
    h = gcf();
else
    if(ishandle(h))
        h = figure(h);
    else
        h = figure();
    end
end

plot(X,Y);

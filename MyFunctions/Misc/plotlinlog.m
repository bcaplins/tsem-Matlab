function [line_handle] = plotlinlog(x,y,linblock,logblock,splitVal)
% linblock -- location of tick mark locations
% logblock -- location of tick mark locations
% splitval -- where the axis splits from linear to log


% example code:

% clear all
% close all
% 
% fakefun = @(t) (t>0).*exp(-t/100)+randn(size(t))/50;
% x = -5:1:10000;
% y = fakefun(x);
% figure(999)
% clf
% linblock = [-5:5:5];
% logblock = [10:10:90 100:100:900 1000:1000:10000];
% splitval = 10;
% 
% cm = lines();
% 
% ph = plotlinlog(x,smooth(y,4),linblock,logblock,splitval)
% ph.Color = cm(1,:);
% 
% ph = plotlinlog(x,y,linblock,logblock,splitval)
% ph.Marker = '.';
% ph.LineStyle = 'none';
% ph.MarkerEdgeColor = cm(2,:);
% 



gcf();
hold on

xorig = [linblock logblock];
xticks = xorig;

% Find what fraction of displayed x-axis is linear and what fraction is
% logarithmic.  Set this split ratio
x1 = log10(splitVal);
x2 = log10(xorig(end));

% dx = (x2-x1);

dxLin = splitVal - min(xorig);

% Fraction of scale to dedicate to linear portion
f = 0.3;
scale = @(x)(log10(x)-x1)/(x2-x1)*dxLin*(1/f-1)+splitVal;

% % Alternatively each block can get one 'unit'
% scale = @(x)(log10(x)-x1)/(x2-x1)*dxLin*(log10(max(x)))+splitVal;
% Apply scaling to ticks 
xticks(xticks>splitVal) = scale(xticks(xticks>splitVal));


% Apply scaling to data         
x(x>splitVal) = scale(x(x>splitVal));

% Plot it and set ticks
line_handle = plot(x,y)


% xlim([min(xticks) max(xticks)])
xlim([min(x) max(x)])
set(gca,'XTick',xticks);



% Generate a select subset of tick labels
for i=1:length(xorig)
    if(xorig(i)<=splitVal)
        xl{i} = sprintf('%0.1f',xorig(i));
    else
        if(mod(log10(xorig(i)),1)<2*eps)
            round(log10(xorig(i)))
            xl{i} = ['10^' num2str(round(log10(xorig(i))))];
        else
            xl{i} = '';
        end
    end
end

set(gca,'XTickLabel',xl)

yl = get(gca,'YLim');
plot([1 1]*splitVal,yl,'--','Color',[1 1 1]*.4)
ylim(yl)


xlabel('time (units?)')
ylabel('signal (units?)')



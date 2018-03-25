
clear all
close all

% create some fake data
f = @(x) 1-(1*exp(-x.^2/10)+1*exp(-x/100))+1
x = linspace(1e0,1e4,2^22);
y = f(x)+randn(size(x))/8;

% plot all the data
figure(1)
clf
h = scatter(x,y,100,'.','MarkerEdgeAlpha',1)
ax = gca();
ax.XScale = 'log';
ax.YScale = 'log';
ylim([1e-1 3e0])

% Create a new, log spaced axis
x_resampled = logspace(0,4,2^10);
y_resampled = zeros(size(x_resampled));

% ensure that the spacing between the first two elements in your log spaced
% axis is always greater than your sampling time (delta t).  Otherwise you
% will have zero samples in some of the new bins
delOld = diff(x(1:2));
delNew = diff(x_resampled(1:2));
if(delNew<=delOld)
    error('Change the resampled axis')
end

% For each new bin find the data points close to it in the original data
% set and take the mean y value.  Watch out for edge effects.
for i=2:(length(x_resampled)-1)
    % Find the midpoints between the new sampling points
    x_back = (x_resampled(i)+x_resampled(i-1))/2;
    x_forward = (x_resampled(i+1)+x_resampled(i))/2;
    % Use a binary search to find the data that falls into these bins
    [l_idx, r_idx] = findInSorted(x,[x_back,x_forward-eps]);
    y_resampled(i) = mean(y(l_idx:r_idx));
end

% Throw out the first and last points (edge effects)
x_resampled = x_resampled(2:end-1);
y_resampled = y_resampled(2:end-1);

% Any negative values are set to eps to prevent NaN's
y_resampled(y_resampled<=0) = eps;

% Plot the result
hold on
plot(x_resampled,y_resampled,'.-')
xlim([1e-1 1e5])
ylim([1e-2 1e1])


function [b,c]=findInSorted(x,range)
    %findInSorted fast binary search replacement for ismember(A,B) for the
    %special case where the first input argument is sorted.
    %   
    %   [a,b] = findInSorted(x,s) returns the range which is equal to s. 
    %   r=a:b and r=find(x == s) produce the same result   
    %  
    %   [a,b] = findInSorted(x,[from,to]) returns the range which is between from and to
    %   r=a:b and r=find(x >= from & x <= to) return the same result
    %
    %   For any sorted list x you can replace
    %   [lia] = ismember(x,from:to)
    %   with
    %   [a,b] = findInSorted(x,[from,to])
    %   lia=a:b
    %
    %   Examples:
    %
    %       x  = 1:99
    %       s  = 42
    %       r1 = find(x == s)
    %       [a,b] = myFind(x,s)
    %       r2 = a:b
    %       %r1 and r2 are equal
    %
    %   See also FIND, ISMEMBER.
    %
    % Author Daniel Roeske <danielroeske.de>

    A=range(1);
    B=range(end);
    a=1;
    b=numel(x);
    c=1;
    d=numel(x);
    if A<=x(1)
       b=a;
    end
    if B>=x(end)
        c=d;
    end
    while (a+1<b)
        lw=(floor((a+b)/2));
        if (x(lw)<A)
            a=lw;
        else
            b=lw;
        end
    end
    while (c+1<d)
        lw=(floor((c+d)/2));
        if (x(lw)<=B)
            c=lw;
        else
            d=lw;
        end
    end
end

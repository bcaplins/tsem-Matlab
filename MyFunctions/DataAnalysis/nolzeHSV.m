function cm = nolzeHSV(num)
%NOLZEHSV Summary of this function goes here
%   Detailed explanation goes here

v = @(r) 0.5+exp(-(4/7)*wrapit(r).^2)+exp(-(4/7)*wrapit(r-2*pi/3).^2)+exp(-(4/7)*wrapit(r+2*pi/3).^2)

hn = integral(v,0,2*pi)

angles = linspace(0,2*pi,num+1);
angles = angles(1:end-1);

hsvs = zeros(length(angles),3);
for i=1:length(hsvs)
    hsvs(i,:) = [integral(v,0,angles(i))./hn 1 1];
end

figure
% plot(diff(hsvs(:,1)))
plot(v(angles))


cm = hsv2rgb(hsvs);


figure(2)
clf

N_h = 16;
cm_band1 = permute(repmat(cm,[1 1 N_h]),[3 1 2]);
% imshow(cm_band)

% N_h = 16;
% cm_band2 = permute(repmat(hsv(num),[1 1 N_h]),[3 1 2]);
N_h = 16;
linhsv = zeros(num,3);
huey = linspace(0,1,num+1);
huey = huey(1:end-1);

for i=1:num
    linhsv(i,:) = [huey(i) 1 1];
end

cm2 = hsv2rgb(linhsv);


N_h = 16;
cm_band2 = permute(repmat(cm2,[1 1 N_h]),[3 1 2]);


imshow([cm_band1; cm_band2])


% permute(


end

function s = wrapit(r)
    s = r;
    s(r>pi) = s(r>pi)-2*pi;
end


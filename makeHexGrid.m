clear all
    close all


% %%    
% 
%     N = 2; % N=4 is 217 points
% 
%     rot = @(rad) [cos(rad) -sin(rad);
%                     sin(rad) cos(rad)];
% 
%     % Create (redundant) lattice
%     a = (1/N)*1000*[1 0]';
%     b = rot(60*pi/180)*a;
%     c = rot(-60*pi/180)*a;
% 
%     points = zeros(2,(2*N+1)^3);
% 
%     idx = 0;
% 
%     for i=-N:N
%         for j=-N:N
%             for k=-N:N
%                 idx = idx+1;
%                 points(:,idx) = i*a+j*b+k*c;
%             end
%         end 
%     end
% 
%     % Remove replicated
%     points = points';
%     points = sortrows(points);
%     points = uniquetol(points,1e-6,'ByRows',true);
%     points = points';
% 
%     size(points)

    
%


t = linspace(0,10,2^6);
r = 200*t+100;
th = 2*pi*t;

points = zeros(2,length(t));

points(1,:) = r.*cos(th);
points(2,:) = r.*sin(th);
    
points = [[0;0] points];
%     
figure(1231),clf
hold on
plot(points(1,:),points(2,:),'-o')
axis equal


% Convert all points to polar coordinates
polarcoords = zeros(size(points)); %theta,r

for i=1:length(points)
    polarcoords(1,i) = 180*atan2(points(2,i),points(1,i))/pi;
    polarcoords(2,i) = sqrt(points(1,i)^2+points(2,i)^2);
end

figure(1231)
clf
polar((pi/180)*polarcoords(1,:),polarcoords(2,:),'o')

clear semParams;


Xbeam = zeros(size(polarcoords));
MAG = 72;

WD = 22.72;
for i=1:length(polarcoords)
    semParams(i) = BasicSEMScanParameters(WD,MAG,1,-polarcoords(1,i));
    Xbeam(:,i) = ImageMapping.mapFromNonrotatedSpatialCoordsToRotatedBeamCoords(points(:,i),semParams(i));
end


img_dir = 'Z:\20171129\hexlattice\'
cmos_args = CMOSArgs(15,0,160);
fnames = collectCMOSSpotImages(img_dir,cmos_args,Xbeam,semParams)

[fm,fv] = calculateCMOScalib(img_dir,fnames,Xbeam,semParams,0.15)


return
for i=1:length(fnames)
    delete(fnames{i});
end


fm = [-1.1325    9.4311
    9.4895    2.1308];

fv = 1.0e+04 *[  -0.3400
   -1.1182];











img = MonochromeImage('MAX_CMOS_STACK.png');
img.imgType = ImageTypes.CMOS;
imgMap = ImageMapping(fm,fv,eye(2),eye(2),0);

yagimg = imgMap.doMapping(img,ImageTypes.YAG)


figure(14321)
clf
plot(yagimg)
hold on
plot(points(1,:),points(2,:),'or')

popts = cell(length(points));

ssrs = zeros(1,length(points));    

for i=1:length(points)
    ang_guess = polarcoords(1,i);
    if(ang_guess<0)
        ang_guess = ang_guess+360;
    end
    
    ang_guess = 0 ;
    
    DEL = 80;
    
    
    xidxs = find(yagimg.X(1,:)>=(points(1,i)-DEL) ...
        & (yagimg.X(1,:)<=(points(1,i)+DEL)));
    
    yidxs = find((yagimg.Y(:,1)>=(points(2,i)-DEL)) ...
        & (yagimg.Y(:,1)<=(points(2,i)+DEL)));
    
    X = yagimg.X(yidxs,xidxs);
    Y = yagimg.Y(yidxs,xidxs);
    dat = yagimg.img(yidxs,xidxs);
    
%     mean(min(dat))

    sdat = sort(dat(:));
    

    off_guess = mean(sdat(1:floor(length(sdat/10))));
    amp_guess = mean(sdat(end-4:end))-off_guess;
    
    hiidxs = find(dat>((amp_guess/2)+off_guess));
    
    x0guess = mean(X(hiidxs));
    y0guess = mean(Y(hiidxs));
    
    
    
    
        
%     p0 = [points(1,i) points(2,i) 10 10 amp_guess off_guess  pi*ang/180];
    p0 = [x0guess y0guess 10 10 amp_guess off_guess  pi*ang_guess/180];
    
  
    OLS = @(p) sum(sum((dat-general2dGaussian(X,Y,p)).^2));
    opts = optimset('MaxFunEvals',100000,...
        'MaxIter',100000,...
        'TolX', 1e-6,...
        'TolFun', 1e-6);
    [popt,fval,exitflag,output] = fminsearch(OLS,p0,opts)
    
    ssrs(i) = OLS(popt);
    
    
%     popt = p0;
    
    figure(1111)
    clf
    contourf(X,Y,dat,'EdgeColor','none');
    caxis([0 1])
    hold on
    contour(X,Y,general2dGaussian(X,Y,popt),(0.5*(popt(5)-popt(6))+popt(6))*[1 1],'k')
    axis square
    pause(0.001)
% pause
    
    popts{i} = popt;
    i
    
end



figure(12312)
clf
hold on
for i=1:length(popts)
    pp = polarcoords(1,i);
    if(pp<0)
        pp = pp+360;
    end
    
    plot(pp,(180/pi)*popts{i}(end),'o')
    
    
    
end
   

figure(12314)
clf
hold on

fwhm = @(s) s*2*sqrt(2*log(2));


for i=1:length(popts)
    polarcoords(2,i);
    
    
    psf(i) = mean([fwhm(popts{i}(3)),fwhm(popts{i}(4))]);
    
%     plot(polarcoords(2,i),popts{i}(3)/popts{i}(4),'o')
    plot(polarcoords(2,i),psf(i),'.k')
    
end
ylim([0 40])




figure(234123412)
clf 
hold on

% tri = delaunay(points(1,:)',points(2,:)');

% dt = trisurf(tri,points(1,:)',points(2,:)',psf');

F = scatteredInterpolant(points(1,:)',points(2,:)',psf','nearest','none');

x = linspace(-2000,2000,2^10);
y = linspace(-2000,2000,2^10);

[Xq Yq] = meshgrid(x,y);

Zq = F(Xq,Yq);

surf(Xq,Yq,Zq,'EdgeColor','none')
colormap(flipud(hot))
	
caxis([15 40])

colorbar
axis square



xlim([min(points(1,:)) max(points(1,:))])
ylim([min(points(2,:)) max(points(2,:))])




























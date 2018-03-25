e = 1.60217662e-19; % charge on elec
h = 6.62607004e-34; % plancks
lam =  getElectronWavelength(30000); % At 10 keV
t = 5e-9; % nanometers
B0 = 2.15; % tesla (iron)

beta = e*B0*lam*t/h


dat = parseOutputNew('5nm_Fe_30keV.dat',1,500000,1);
dis = calculateAngleDistLogAxis(dat,2^9);

% convert to solid angle normalized 
x = dis.x;
p = dis.pTotal./(2*pi*sin(x));

% Assume flat angular dist within central disc
idxs = find(x>1e-4 & x<1e-3);
mean_val = mean(p(idxs));
p(x<1e-3) = mean_val;

% ensure it is normalized
p = p./trapz(x,2*pi*sin(x).*p);

disp('Frac of electrons in brightfield cone')
idxs = find(x<1e-3);
trapz(x(idxs),2*pi*sin(x(idxs)).*p(idxs))


% Measure transmission through aperature
CL = 10;
Ro = 1;

xx = logspace(-6,log10(1),2^9);
xx = [-fliplr(xx) xx];
yy = logspace(-6,log10(1),2^9);
yy = [-fliplr(yy) yy];
[X Y] = meshgrid(xx,yy);

R = sqrt(X.^2+Y.^2);
THETA = atan(R/CL);

I = interp1(x,p,THETA(:));
I = reshape(I,size(THETA));

% Apply jacobian
I = I.*sin(THETA).*cos(THETA).*cos(THETA)./R./CL;

figure(2131345)
clf
hold on
s = surf(X,Y,log(1+I));
s.LineStyle = 'none';

idxs = find(xx>0);
I_norm = trapz(yy,trapz(xx(idxs),I(:,idxs),2))

max_disc_shift = tan(beta)*CL

idxs = find(xx>max_disc_shift);
I_shifted = trapz(yy,trapz(xx(idxs),I(:,idxs),2))

dI = I_norm-I_shifted

c_per_e = 1.60217733e-19;
I_beam = 30e-12;
e_per_s = I_beam/c_per_e;
pix_per_image = 1024*768/4;
sec_per_image = 120;

e_per_pix = e_per_s*sec_per_image/pix_per_image;

rel_err = sqrt(e_per_pix)/e_per_pix











theta = 12*pi/180;
theta_p = atan(tan(theta)/sqrt(2))

alpha = linspace(12-5,12+5,1000)*pi/180;

alpha_p = atan(tan(alpha)/sqrt(2));

beta_p = 2*theta_p-alpha_p;

d = 13.7e-6;
lam = 550e-9;

m = (2*d/lam)*(sin(alpha_p)+sin(beta_p))


figure

plot(alpha_p*180/pi,rem(abs(m-round(m)),1))
grid on





alpha = (0)*pi/180;
d = sqrt(2)*13.7e-6;
lam = 550e-9;
m=0:20;

[M A] = meshgrid(m,alpha);

beta  = asin(M*lam/d-sin(A))*180/pi;


figure(123421341)
clf
mesh(M,A,beta)

2*d*sin(12*pi/180)*cos(-12*pi/180)







DMD_x = linspace(-2,2,2^10);
max_ang_inc = max(atan(DMD_x/150))*180/pi
cent_ang_inc = atan(DMD_x/150)

m = 0:20;

for i=1:length(cent_ang_inc)
    alpha = cent_ang_inc(i);
    betas  = asin(m*lam/d-sin(alpha));
    
    eff_x = DMD_x(i)*cos(24*pi/180);
    max_collect_angle = atan(
    min_collect_angle = 
    
end

















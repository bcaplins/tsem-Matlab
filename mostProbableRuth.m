clear all
close all

N = 606;

fn = 'Si30keV.H64';
fid = fopen(fn);
X = textscan(fid,'%f%f',N,'Headerlines',12)

a02 = 2.8002852e-21;

Six = X{1}*pi/180;
Siy = 2*pi*sin(Six).*X{2}*a02;


fclose(fid);


Si = loadNistDCS('Al',30)




% 
% fn = 'C:\Users\bwc\Desktop\N30keV.H64';
% fid = fopen(fn);
% X = textscan(fid,'%f%f',N,'Headerlines',12)
% 
% Nx = X{1}*pi/180;
% Ny = 2*pi*sin(Nx).*X{2}*a02;
% 
% fclose(fid);
% 
% 
% N = 606;
% 
% fn = 'C:\Users\bwc\Desktop\Al.H64';
% fid = fopen(fn);
% X = textscan(fid,'%f%f',N,'Headerlines',12)
% 
% a02 = 2.8002852e-21;
% 
% Alx = X{1}*pi/180;
% Aly = 2*pi*sin(Six).*X{2}*a02;
% 
% 
% fclose(fid);



figure(4321)
% clf
hold on
% plot(Nx,Ny)
plot(Six,Siy)

% plot(Alx,Aly)
% legend('N','Si','Al')

xlabel('radians')
ylabel('d\sigma_{elastic}/d\theta (m^2/radians)')


[mv mi] = max(Siy)
Six(mi)
% 
% [mv mi] = max(Ny)
% Nx(mi)

sigN = 8.588474E-02*2.8002852E-21
sigSi = 2.868777E-01*2.8002852E-21
NA = 6.022e23;

mW  = 12;
rho = 3.2;
N = rho*1e6*NA/mW;

lam = 1/(N*.012e-20)






cs = (2.5e-1*2.8e-21); % m^2

Na = 6.022e23;

ma = 27; % gram/mol

rho = 2.7 *1e6;% gram / m^3

N = Na*rho/ma
lambda = 1/(N*cs)








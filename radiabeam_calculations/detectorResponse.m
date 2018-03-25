clear all
close all



Z = 14;
Ethresh = 3000; %eV
Ehp = 3.6;

eff = 1;

I0 = 1;

eta_ang = @(th,Z) (1+cos(th)).^(-9./sqrt(Z))

m_var = @(Z) 0.1382-0.9211./sqrt(Z);
C_var = @(Z) 0.1904-0.2235*log(Z)+0.1292*(log(Z).^2)-0.01491*(log(Z).^3)
eta_E = @(Z,E) C_var(Z).*E.^(m_var(Z)) % in keV

eta = @(th,E,Z) eta_E(Z,E/1000).*eta_ang(th,Z)./eta_ang(0,Z)
% eta = @(th,E,Z) eta_ang(th,Z)/eta_ang(0,Z)

I = @(E,th) I0.*(1-eta(th,E,Z)).*((E-Ethresh)./Ehp).*eff



xs = linspace(0, 1, 2^10);
ys = linspace(Ethresh, 10000, 2^10);

[ths Es] = meshgrid(xs,ys);

figure(12321)
clf
contourf(ths,Es,I(Es,ths))
% mesh(ths,Es,eta(ths,Es,14))


xlabel('theta (rad)')
ylabel('energy (eV)')
zlabel('I_{cc}')

figure(123243)
clf
hold on
% Zs= 6:100;
% plot(Zs,eta(0,5000,Zs),'^k')
% plot(Zs,eta(0,10000,Zs),'o')
% plot(Zs,eta(0,20000,Zs),'d')
% plot(Zs,eta(0,30000,Zs),'o')
% plot(Zs,eta(0,40000,Zs),'sk') 
% plot(Zs,eta(0,50000,Zs),'^') 
angs = 0:90;
plot(angs,eta(pi*angs/180,10000,79))
plot(angs,eta(pi*angs/180,10000,47))
plot(angs,eta(pi*angs/180,10000,29))
plot(angs,eta(pi*angs/180,10000,13))
plot(angs,eta(pi*angs/180,10000,6))

ylim([0 1])
xlim([0 90])
grid on



plot(xs,I(ys,0))
ylim([0 inf])









%%%%%

deltaScat = linspace(-0.2,0.2,2^10);
deltaResp = linspace(-0.2,0.2,2^10);

[deltaScat deltaResp] = meshgrid(deltaScat,deltaResp);


I0 = 1;
resp = 1;

IL = (1+deltaScat)*0.5*I0;
IR = (1-deltaScat)*0.5*I0;

respL = resp*(1+deltaResp);
respR = resp*(1-deltaResp);

iL = respL.*IL;
iR = respR.*IR;


di = ((iR-iL)./(iR+iL));

figure

contourf(deltaScat,deltaResp,di)

xlabel('deltaScat (material response)')
ylabel('deltaResp (detector response difference)')










E0 = 10;
Au = 10;% nm
% angle degree, energy absorbed Si, Au
dat10keV = [0 8.067 0.3215
       10 8.028 0.3265
       20 7.823  0.354
       30 7.627 0.3794
       40 7.223 0.433
       50 6.629 0.504
       60 5.784 0.5793
       70 4.92 0.6545
       80 3.666 0.6406];
   
   rads = dat10keV(:,1)*pi/180;
   
   figure(32141324)
   clf
   hold on
   
   MC10  = dat10keV(:,2)./E0;
%    MC10 = MC10./max(MC10);

eta_ang = @(th,Z) (1+cos(th)).^(-9/sqrt(Z))
   
ANAL10 = 1-eta(rads,E0*1000,14);
% ANAL10 = ANAL10./max(ANAL10);

% plot(rads,MC)
% plot(rads,ANAL)
% ylim([0 inf])

% plot(rads,(MC-ANAL)./MC)
% ylim([-1 1]*0.1)
% grid on



E0 = 5;
Au = 10;% nm
% angle degree, energy absorbed Si, Au
dat5keV = [0 3.243 0.5594
       10 3.212 0.5618
       20 3.095 0.5892
       30 2.96 0.6332
       40 2.767 0.6836
       50 2.486 0.7641
       60 2.132 0.8182
       70 1.719 0.8268
       80 1.292 0.7371];
   
   rads = dat5keV(:,1)*pi/180;
   
   figure(32141324)
   clf
   hold on
   
   MC5  = dat5keV(:,2)./E0;
%    MC5 = MC5./max(MC5);

eta_ang = @(th,Z) (1+cos(th)).^(-9/sqrt(Z))
   
ANAL5 = 1-eta(rads,E0*1000,14);
% ANAL5 = ANAL5./max(ANAL5);

% plot(rads,MC)
% plot(rads,ANAL)
% ylim([0 inf])

% plot(rads,(MC-ANAL)./MC)
% ylim([-1 1]*0.2)
% grid on






E0 = 30;
Au = 10;% nm
% angle degree, energy absorbed Si, Au
dat30keV = [0 26.76 0.1234
       10 26.51 0.129
       20 26.1 0.1366 
       30 25.51 0.1505
       40 24.45 0.1753
       50 23.1 0.212
       60 20.81 0.277
       70 17.49 0.3847
       80 13.01 0.4943];
   
   rads = dat30keV(:,1)*pi/180;
   
   figure(32141324)
   clf
   hold on
   
   MC30  = dat30keV(:,2)./E0;
%    MC30 = MC30./max(MC30);

eta_ang = @(th,Z) (1+cos(th)).^(-9/sqrt(Z))
   
ANAL30 = 1-eta(rads,E0*1000,14);
% ANAL30 = ANAL30./max(ANAL30);
% 
% plot(rads,MC)
% plot(rads,ANAL)
% ylim([0 inf])

% plot(rads,(MC-ANAL)./MC)
% ylim([-1 1]*0.03)
grid on





figure(13241)
clf
hold on
cm = lines;
plot(rads,MC5,'Color',cm(1,:))
plot(rads,MC10,'Color',cm(2,:))
plot(rads,MC30,'Color',cm(3,:))
plot(rads,ANAL5,'--','Color',cm(1,:))
plot(rads,ANAL10,'--','Color',cm(2,:))
plot(rads,ANAL30,'--','Color',cm(3,:))

legend('5 keV (MC)','10 keV (MC)','30 keV (MC)','5 keV (\eta)','10 keV (\eta)','30 keV (\eta)')
title('MC vs Empirical 1-\eta(E,Z,\theta)')

xlim([0 1])
ylabel('E_{abs}/E_0')
xlabel('\theta (radians)')
ylim([0 1])
grid on


figure(13241)
clf
hold on
cm = lines;
MC5 = MC5./max(MC5);
MC10 = MC10./max(MC10);
MC30 = MC30./max(MC30);
ANAL5 = ANAL5./max(ANAL5);
ANAL10 = ANAL10./max(ANAL10);
ANAL30 = ANAL30./max(ANAL30);
plot(rads,MC5,'Color',cm(1,:))
plot(rads,MC10,'Color',cm(2,:))
plot(rads,MC30,'Color',cm(3,:))
plot(rads,ANAL5,'--','Color',cm(1,:))
plot(rads,ANAL10,'--','Color',cm(2,:))
plot(rads,ANAL30,'--','Color',cm(3,:))

legend('5 keV (MC)','10 keV (MC)','30 keV (MC)','5 keV (\eta)','10 keV (\eta)','30 keV (\eta)')


title('MC vs Empirical 1-\eta(E,Z,\theta)')

xlim([0 1])
ylabel('E_{abs}/E_0 (normalized)')
xlabel('\theta (radians)')
ylim([0 1])
grid on



return










% 0 deg AOI
% E E_abs
datNormal = [1 0.013
            1.5 0.161
            2 0.465
            2.5 0.882
            3 1.296
            4 2.259
            5 3.229
            6 4.175
            8 6.089
            10 8.04
            14 11.88
            18 15.54
            22 19.37
            26 22.92
            30 26.65
            50 45.48
            60 54.6]
        
figure()
plot(datNormal(:,1),1000*datNormal(:,2)./Ehp)
% hold on
% plot(datNormal(:,1),1000*datNormal(:,1)./Ehp,'k--')
x = datNormal(:,1);
y = 1000*datNormal(:,2)./Ehp;
idxs = find(x>=4);
P = polyfit(x(idxs),y(idxs),1);
X_int = -P(2)/P(1);
hold on
plot([0 30],polyval(P,[0 30]),'--')
text(5,6500,['gain(E) = ' num2str(P(1)) '*E + ' num2str(P(2))])
text(5,5500,['E_{thresh} = ' num2str(X_int) ' keV'])
text(5,7500,['10 nm Au on Si; E_{hp}=3.6 eV'])

title('MC model of detector response')

xlim([0 30])
ylim([0 8]*1000)
grid on




            
figure()
plot(datNormal(:,1),datNormal(:,2)./datNormal(:,1),'k--')

xlim([0 60])
ylim([0 1])
grid on     





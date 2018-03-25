clear all
close all

figure(123)
clf
hold on

wd = '.\';

fns = {'PMT_Sensitivity_data_01.txt'
'PMT_Sensitivity_data_20.txt'
'yag_ce_spectra.txt'
'PMT_Sensitivity_data_210.txt'
'yag_ce_spectra_with_uv.txt'
'CRY18_Lum_data.txt'}


pmt_01 = csvread([wd fns{1}],1,0);
pmt_20 = csvread([wd fns{2}],1,0);
yag_out = csvread([wd fns{3}],1,0);
pmt_210 = csvread([wd fns{4}],1,0);
yag2_out = csvread([wd fns{5}],1,0);
cry18_out = csvread([wd fns{6}],1,0);

% figure(123)
% clf
% hold on
% plot(yag2_out(:,1),yag2_out(:,2))
% return

pmt_01 = sortrows(pmt_01,1);
pmt_20 = sortrows(pmt_20,1);
yag_out = sortrows(yag_out,1);
yag2_out = sortrows(yag2_out,1);
pmt_210 = sortrows(pmt_210,1);
cry18_out = sortrows(cry18_out,1);

pmt_01(:,2) = smooth(pmt_01(:,2),40);
pmt_20(:,2) = smooth(pmt_20(:,2),40);
yag_out(:,2) = smooth(yag_out(:,2),40);
yag2_out(:,2) = smooth(yag2_out(:,2),40);
pmt_210(:,2) = smooth(pmt_210(:,2),40);
cry18_out(:,2) = smooth(cry18_out(:,2),40);

plot(pmt_01(:,1),pmt_01(:,2))
plot(pmt_20(:,1),pmt_20(:,2))
plot(yag_out(:,1),yag_out(:,2))

return
x = 250:700;

yag_out_sp = zeros(size(x));
idxs = find(x>=455 & x<=699);
yag_out_sp(idxs) = interp1(yag_out(:,1),yag_out(:,2),x(idxs));
yag_out_sp(find(isnan(yag_out_sp))) = 0;


yag2_out_sp = zeros(size(x));
idxs = find(x>=220 & x<=630);
yag2_out_sp(idxs) = interp1(yag2_out(:,1),yag2_out(:,2),x(idxs));

cry18_out_sp = zeros(size(x));
idxs = find(x>=215 & x<=550);
cry18_out_sp(idxs) = interp1(cry18_out(:,1),cry18_out(:,2),x(idxs));
cry18_out_sp(find(isnan(cry18_out_sp))) = 0;






% Yaxis Volt/nW at 10^5 gain
% with 10^6 A->V gain
% Divide by 100 to get A/W

% Then convert to QE via (1240/lambda)*Sk

pmt_01_qe = (1240./x).*(1/100).*interp1(pmt_01(:,1),pmt_01(:,2),x);
pmt_20_qe = (1240./x).*(1/100).*interp1(pmt_20(:,1),pmt_20(:,2),x);
pmt_210_qe = (1240./x).*(1/100).*interp1(pmt_210(:,1),pmt_210(:,2),x);

pmt_01_R = (20/1000)*interp1(pmt_01(:,1),pmt_01(:,2),x);
pmt_20_R = (20/1000)*interp1(pmt_20(:,1),pmt_20(:,2),x);
pmt_210_R = (20/1000)*interp1(pmt_210(:,1),pmt_210(:,2),x);



h = area(x,0.1*max(yag_out_sp,yag2_out_sp),'FaceColor',0.85*[1 1 1],'LineStyle','none')
% h = area(x,0.1*yag2_out_sp,'FaceColor',0.55*[1 1 1],'LineStyle','none')
h = area(x,0.1*cry18_out_sp,'FaceColor',0.25*[1 1 1],'LineStyle','none')
plot(x,pmt_01_qe)
plot(x,pmt_20_qe)
plot(x,pmt_210_qe)

title('Hamamatsu Model H10722-XXX PMT')
ylabel('QE')
xlabel('\lambda (nm)')
legend('YAG:Ce Fl','CRY18 Fl','-01','-20','-210')
grid on

saveas(gcf(),'pmt_QE.pdf')

pause

clf
hold on

h = area(x,0.1*max(yag_out_sp,yag2_out_sp),'FaceColor',0.85*[1 1 1],'LineStyle','none')
% h = area(x,0.1*yag2_out_sp,'FaceColor',0.55*[1 1 1],'LineStyle','none')
h = area(x,0.1*cry18_out_sp,'FaceColor',0.25*[1 1 1],'LineStyle','none')
plot(x,pmt_01_R)
plot(x,pmt_20_R)
plot(x,pmt_210_R)


title('Hamamatsu Model H10722-XXX PMT')
ylabel('V/pW (V_C=1V, 2e6 gain)')
xlabel('\lambda (nm)')
legend('YAG:Ce Fl','CRY18 Fl','-01','-20','-210')
grid on

saveas(gcf(),'pmt_VnW.pdf')
% 
% clf
% hold on





return









plot(x,pmt_01_sp.*yag_out_sp)
plot(x,pmt_20_sp.*yag_out_sp)

sum(pmt_01_sp.*yag_out_sp)
sum(pmt_20_sp.*yag_out_sp)








N_s = 100;
N_b = 0.1*N_s;


S = N_s-N_b;
N = sqrt(N_s+N_b)+sqrt(N_b);

S/N







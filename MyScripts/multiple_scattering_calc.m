clear all
% close all


element = 'C';
EHT_kV = 30;
thickness = 30e-9;

[ths IRF MS] = computeMultipleScatteringDistribution(element,EHT_kV,thickness);

figure(142132)
clf
hold on
plot(ths,IRF)
plot(ths,MS)


xlim([0 0.2])

xlabel('rad')
ylabel('I/d\theta (norm)')




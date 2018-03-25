% [thetas_C zero_scat_prob_C eff_dsc_C] = computeMultipleScatteringDistribution('C',30,90e-9);
% zero_scat_prob_C
% 
% [thetas_Si zero_scat_prob_Si eff_dsc_Si] = computeMultipleScatteringDistribution('Si',30,59e-9);
% zero_scat_prob_Si
% 
% [thetas_Ge zero_scat_prob_Ge eff_dsc_Ge] = computeMultipleScatteringDistribution('Ge',30,27e-9);
% zero_scat_prob_Ge
% 
% [thetas_Sn zero_scat_prob_Sn eff_dsc_Sn] = computeMultipleScatteringDistribution('Sn',30,17e-9);
% zero_scat_prob_Sn
% 
% [thetas_Pb zero_scat_prob_Pb eff_dsc_Pb] = computeMultipleScatteringDistribution('Pb',30,14.5e-9);
% zero_scat_prob_Pb
% 
% [thetas_C zero_scat_prob_C eff_dsc_C] = computeMultipleScatteringDistribution('C',30,100e-9);
% zero_scat_prob_C
% 
% [thetas_Si zero_scat_prob_Si eff_dsc_Si] = computeMultipleScatteringDistribution('Si',30,100e-9);
% zero_scat_prob_Si
% 
% [thetas_Ge zero_scat_prob_Ge eff_dsc_Ge] = computeMultipleScatteringDistribution('Ge',30,100e-9);
% zero_scat_prob_Ge
% 
% [thetas_Sn zero_scat_prob_Sn eff_dsc_Sn] = computeMultipleScatteringDistribution('Sn',30,100e-9);
% zero_scat_prob_Sn
% 
% [thetas_Pb zero_scat_prob_Pb eff_dsc_Pb] = computeMultipleScatteringDistribution('Pb',30,100e-9);
% zero_scat_prob_Pb
% 
% 

figure(123)
clf
hold on


[dsc ann_dsc] = loadNistDCS('C',30);
cs = getElasticCSfromDSC('C',30);
% plot(ann_dsc(:,1),ann_dsc(:,2))
plot(ann_dsc(:,1),ann_dsc(:,2)./max(ann_dsc(:,2)))

[dsc ann_dsc] = loadNistDCS('Si',30);
cs = getElasticCSfromDSC('Si',30);
% plot(ann_dsc(:,1),ann_dsc(:,2))
plot(ann_dsc(:,1),ann_dsc(:,2)./max(ann_dsc(:,2)))

[dsc ann_dsc] = loadNistDCS('Ge',30);
cs = getElasticCSfromDSC('Ge',30);
% plot(ann_dsc(:,1),ann_dsc(:,2))
plot(ann_dsc(:,1),ann_dsc(:,2)./max(ann_dsc(:,2)))

[dsc ann_dsc] = loadNistDCS('Sn',30);
cs = getElasticCSfromDSC('Sn',30);
% plot(ann_dsc(:,1),ann_dsc(:,2))
plot(ann_dsc(:,1),ann_dsc(:,2)./max(ann_dsc(:,2)))

[dsc ann_dsc] = loadNistDCS('Pb',30);
cs = getElasticCSfromDSC('Pb',30);
% plot(ann_dsc(:,1),ann_dsc(:,2))
plot(ann_dsc(:,1),ann_dsc(:,2)./max(ann_dsc(:,2)))



xlim([0 1])

legend('C','Si','Ge','Sn','Pb')
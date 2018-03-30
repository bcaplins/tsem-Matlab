clc
clear all
close all


beam_current = 267e-12/100;
EL_PER_C = 6.24150934e18;

el_per_sec = beam_current*EL_PER_C;

dwell_time = 1/20000;

el_per_pix_avg = el_per_sec*dwell_time;




% ph_det_per_el_avg = PH_PER_EL*PH_COUPLING_EFF*QE


% ph_det_per_el_avg = 2


effs = logspace(-3,2,32);


% for k=1:length(effs)
%     
%     ph_det_per_el_avg = effs(k)
% 
% 
%     PH_PER_EL = 788;
%     PH_COUPLING_EFF = 2.0391e-04;
%     QE = 0.0969;
% 
% 
%     N_PIX = 1024;
% 
%     el_per_pix_sim = zeros(N_PIX,1);
%     % ph_gen_per_pix_sim = zeros(N_PIX,1);
%     ph_det_per_pix_sim = zeros(N_PIX,1);
%     for i=1:N_PIX
%         el_per_pix_sim(i) = randPoisson(el_per_pix_avg);
%     %     ph_gen_per_pix_sim(i) = randPoisson(PH_PER_EL*el_per_pix_sim(i));
%     %     ph_det_per_pix_sim(i) = randPoisson(PH_PER_EL*PH_COUPLING_EFF*QE*ph_gen_per_pix_sim(i));
%         ph_det_per_pix_sim(i) = randPoisson(ph_det_per_el_avg*el_per_pix_sim(i));
%     %     i
%     end
% 
%     beam_stat_SN = el_per_pix_avg/sqrt(el_per_pix_avg);
% 
%     sim_beam_stat_SN = mean(el_per_pix_sim)/std(el_per_pix_sim)
% 
%     % sim_gen_stat_SN = mean(ph_gen_per_pix_sim)/std(ph_gen_per_pix_sim)
% 
%     sim_det_stat_SN = mean(ph_det_per_pix_sim)/std(ph_det_per_pix_sim)
% 
%     sim_beam_stat_SN/beam_stat_SN
% 
%     res(k) = sim_det_stat_SN/beam_stat_SN
% end


cm = lines;

figure(1231)
clf
% hold on
% semilogx(effs,res,'-')
semilogx(effs,sqrt(effs./(effs+1)))

hold on
plot([min(effs) max(effs)], 1*[1 1],'--','Color',0.6*[1 1 1])
plot([min(effs) max(effs)], 0*[1 1],'--','Color',0.6*[1 1 1])


base_avg = 0.0156;

opt_imp_fac = 7.5833;
na12_imp_fac = 6.1296
na17_imp_fac = 12.2565


plot(base_avg*[1 1], [0 1],'--','Color',cm(2,:))
plot(opt_imp_fac*base_avg*[1 1], [0 1],'--','Color',cm(3,:))
plot(na12_imp_fac*opt_imp_fac*base_avg*[1 1], [0 1],'--','Color',cm(4,:))
plot(na17_imp_fac*opt_imp_fac*base_avg*[1 1], [0 1],'--','Color',cm(5,:))




ylim([-0.1 1.1])
grid on

% title()
xlabel('average photon counts per electron')
ylabel('SN_{obs}/SN_{beam}')



function n = randPoisson(lambda)
    STEP = 500;
    e_val = exp(1);
    STEP_val = exp(STEP);
    lamLeft = lambda;
    k = 0;
    p = 1;
    
    while 1
        k = k+1;
        p = p*rand(1);
        
        if(p<e_val && lamLeft >0)
            if(lamLeft>STEP)
                p = p*STEP_val;
                lamLeft = lamLeft-STEP;
            else
                p = p*exp(lamLeft);
                lamLeft = -1;
            end
        end
        
        
        
        if(p>1)
            continue;
        else
            break;
        end
    end
    n = k-1;
end

function n = randPoissonFast(lambda)
    L = exp(-lambda);
    k = 0;
    p = 1;
    
    while p>L
        k = k+1;
        p = p*rand(1);
    end
    n = k-1;
end
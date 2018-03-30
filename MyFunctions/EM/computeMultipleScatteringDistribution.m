function [thetas zero_scat_prob eff_dsc] = computeMultipleScatteringDistribution(element,EHT_kV,thick_m)

    [dsc ann_dsc] = loadNistDCS(element,EHT_kV);
    cs = getElasticCSfromDSC(element,EHT_kV);

    x = dsc(:,1);
    y = dsc(:,2)/cs;

    % Precompute legendre basis functions on nonlinear axis
    ths = [0 logspace(-4, log10(pi),2^10)];
    N_LEG = 400;
    an = zeros(N_LEG,1);
    precompute = zeros(N_LEG,length(ths));
    tic
    for l_idx=1:N_LEG
        ls = legendre(l_idx-1,cos(ths));
        precompute(l_idx,:) = ls(1,:);
    end
    toc
    disp('Done computing legendre basis functions')

    % Project the annular integrated DSC on the basis
    tic
    S1 = interp1(x,y,ths);
    for l_idx=1:N_LEG
       an(l_idx) = trapz(ths,2*pi*sin(ths).*S1.*precompute(l_idx,:));
    end
    toc
    disp('Done projecting the DSC on the legendre basis functions')

    % Compute the Nth scattering distribution functions
    N_SCAT = 100;
    tic
    Sns = zeros(N_SCAT,length(ths));
    for scat_idx=1:N_SCAT
        for l_idx=1:N_LEG
            Sns(scat_idx,:) = Sns(scat_idx,:) ...
                + (1/4/pi).*(2*(l_idx-1)+1) ...
                *(an(l_idx).^scat_idx).*precompute(l_idx,:);
        end
    end
    toc
    disp('Done computing the Nth scattering DSCs')


    % figure(123141)
    % clf
    % hold on
    % xlim([0 0.1])
    % 
    % for im_idx=1:5
    %     y = 2*pi*sin(ths).*Sns(im_idx,:);
    %     trapz(ths,y)
    %     plot(ths,y)
    %     pause
    % end
    % 


    %%%% Verify that the legendre polynomial reconstruction of the DSC
    % figure(23123)
    % clf
    % hold on
    % 
    % plot(ths,S1)
    % plot(ths,Sns(1,:),'--')
    % xlim([0 0.1])


    thickness = thick_m;
    EMFP = getElasticMFPfromDSC(element,EHT_kV);
    p = thickness/EMFP

    N_POISSON = 100;
    Ims = zeros(N_SCAT,length(ths));

    Nth = 20;
    IRF = exp(-ths.^Nth/(2*0.002.^Nth));
    nrm = trapz(ths,2*pi*sin(ths).*IRF);
    IRF = IRF./nrm;

    tic
    for im_idx=0:N_POISSON
        if(im_idx > 0)
            Ims(im_idx,:) = ((p^(im_idx))/factorial(im_idx)).*exp(-p).*Sns(im_idx,:);
        else
            IRF_contrib = ((p^(im_idx))/factorial(im_idx)).*exp(-p).*IRF;
        end
    end
    toc
    disp('Done computing the poisson weighted Nth scattering contributions')

% 
%     figure(123141), clf, hold on
%     % Plot several contributions to the annular DSC
%     for im_idx=0:5
%         if(im_idx == 0)
%             y = 2*pi*sin(ths).*IRF_contrib;
%             trapz(ths,y)
%             plot(ths,y)
%         else
%             y = 2*pi*sin(ths).*Ims(im_idx,:);
%             trapz(ths,y)
%             plot(ths,y)
%         end
%         pause
%     end


%     figure(142132)
    % Plot summed dsc
%     Itot = sum(Ims,1)+IRF_contrib;
%     y = 2*pi*sin(ths).*Itot;
%     % y = Itot;
%     plot(ths,y)

% 
%     xlim([0 0.2])
% 
%     xlabel('rad')
%     ylabel('I/d\theta (norm)')

    thetas = ths;
    eff_dsc = sum(Ims,1);
    y = 2*pi*sin(ths).*IRF_contrib;
    zero_scat_prob = trapz(ths,y)

end



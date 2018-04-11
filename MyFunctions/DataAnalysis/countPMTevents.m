function [N_events, bin_centers, bin_counts] = countPMTevents(dat,THRESH)
% Assume data is a Nx2 matrix with the first colum in seconds and the
% second column in volts

    


    % Compute derivative of data
    dt = diff(dat(:,1));
    del_t = mean(dt);
    if(sum((abs((del_t-dt)/del_t))>1e-6))
        error('Time axis not linear within 1e-6 tolerance');
    end
    
    % Assumes that the data length is long enough that it contains the
    % digitization levels.  Make sure that is self-consistent with the data
    dv = diff(sort(unique(dat(:,2))));
    del_v = min(sort(dv));
    if(sum((rem(dv./del_v,1))>1e-5))
        error('Voltage digitization not specified within 1e-5 tolerance');
    end
    
    t_prime = dat(1:end-1,1);
    v_prime = diff(dat(:,2))./diff(dat(:,1));

    v_prime_step = del_v/del_t;
    
    
    num_pts = abs(max(v_prime)/v_prime_step)+abs(min(v_prime)/v_prime_step);
    if(num_pts>(2^27))
        error('Attempting to allocated more than 1 GB memory. Check the data input discretization.')
    end
    
    rE = 0:v_prime_step:max(v_prime);
    lE = fliplr(-v_prime_step:-v_prime_step:min(v_prime));
    E = [lE rE]+v_prime_step/2;

    
    % Compute histogram of derivative signal
    [bin_counts E] = histcounts(v_prime,E);
    bin_centers =(E(2:end)+E(1:end-1))/2;    
    
    % If not specified then determine appropriate threshholding
    if(nargin<2)
        x = bin_centers(1:end-1);
        y = bin_counts(1:end-1)./bin_counts(2:end);

        y(~isfinite(y)) = NaN;
        y(abs(y)<eps) = NaN;
        y(end-16:end) = NaN;

        [dummy max_idx] = max(y);

        y_thresh = y(max_idx+1:end);
        y_thresh(isnan(y_thresh)) = [];
        y_thresh = 1.2*median(y_thresh);

        crossing_idx = find(y(max_idx:end)<y_thresh,1)+max_idx-1;

        THRESH = mean(x(crossing_idx-1:crossing_idx));
    end

    bin_counts(bin_counts==0) = eps;
    
    
    figure(14135)
    clf
    cm = lines;
    % plot the histogram
    bar(bin_centers,bin_counts,0.5,'FaceColor',cm(3,:),'EdgeColor','none','LineWidth',1)
%     stairs(E(1:end-1),bin_counts,'Color',cm(2,:),'LineWidth',2)
    ax = gca;
    ax.YScale = 'log';
    hold on
    % plot the threshold
    plot(THRESH*[1 1],[min(bin_counts)+1 max(bin_counts)],'k--')
    xlim([min(bin_centers(bin_counts>0)) max(bin_centers(bin_counts>0))])
    
    % plot the derivative of the histogram which is used for threshold
    % selection
    plot(x,y)
    
    xlabel('dV/dt')
    ylabel('counts')
    
    
    grid on
    
    % Count the events
    N_events = sum(bin_counts(bin_centers>THRESH))/dat(end,1);

    ylim([0.1 inf])
    

end
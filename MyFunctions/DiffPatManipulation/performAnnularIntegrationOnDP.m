function [pix_r ann_int mean_ann_int] = performAnnularIntegrationOnDP(img,step)
% bgfn: filename of corrected background
% fn: filename of corrected diffraction pattern
% p0: pattern center
    
    % when displaying image with bullseye scale by this factor for viewing
    sc_image_factor = 1/1;

    % Plot image with guides to eye
    figure(998833)
    clf
    plot(img)
    hold on

    rtests = [50 100 200 250 300 400 500 1000 2000];
    for rt = rtests
        [cX cY] = genCircle([0 0],rt);
        plot(cX,cY,'k-', 'LineWidth', 1)
    end

    if(step <= 0)
        % kickout early without computing anything
        return
    end


    % maximum radius to go to 
    mx = 4000;

    % starting radius
    r_o = 0;

    % Number of annular rings to step through
    N_rings = floor((mx-r_o)./step);

    % running list of radii and the integral for r<=r_o
    r = zeros(N_rings,1);
    rad_int = zeros(N_rings,1);

    % running list of the number of pixels summed
    nms = zeros(N_rings,1);

    % precompute radii for each pixel
    
    rs = sqrt((img.X).^2+(img.Y).^2);

    loop_idx = 0;
    while r_o<=mx
        loop_idx = loop_idx + 1;

        % store current radius
        r(loop_idx) = r_o;

        % find pixels with radius <=r_o
        idxs = find(rs<=r_o);

        % integration of disc from 0 to r_o
        s = sum(img.img(idxs));
        rad_int(loop_idx) = s;

        % number of pixels in disc from 0 to r_o
        nms(loop_idx) = numel(idxs);

        % Update outer radius
        r_o = r_o+step;
    end

    % The average radii for each annulus in pixels
    pix_r = (r(1:end-1)+r(2:end))/2;

    % The number of pixels in each annulus
    ann_nms = diff(nms);

    % The sum of the pixels in each annulus
    ann_int = diff(rad_int);

    % Average pixel value for each annulus
    mean_ann_int = ann_int./ann_nms;


end
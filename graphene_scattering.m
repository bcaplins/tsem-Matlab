figure(123)
clf
hold on

    % graphene scattering
    lat_const = 0.246e-9;

    EHT = 30000;

    lam = getElectronWavelength(EHT)
    theta_scat = @(d) 2*asin(lam/2/d)

    % Closed form solution I found somewhere
    d_calc = @(h,k)  sqrt((3/4)*lat_const^2/(h^2+h*k+k^2))


    % The brute force approach
    rot = @(theta_rads) [cos(theta_rads) -sin(theta_rads);  sin(theta_rads) cos(theta_rads)];
    real_a = lat_const*[1 0]'
    real_b = rot(120*pi/180)*real_a

    rec_a = 2*pi*rot(pi/2)*real_b/(dot(real_a,rot(pi/2)*real_b))
    rec_b = 2*pi*rot(pi/2)*real_a/(dot(real_b,rot(pi/2)*real_a))

    d_calc_latt_meth = @(h,k) 2*pi/norm(h*rec_a+k*rec_b)



    cm = lines();

    recs = [rec_a rec_b];
    hk = [1 0];
    tmp = recs*(hk');
    radius_1 = norm(tmp);
    plot(tmp(1),tmp(2),'o','Color',cm(1,:))
    hk = [0 1];
    tmp = recs*(hk');
    plot(tmp(1),tmp(2),'o','Color',cm(1,:))
    hk = [-1 0];
    tmp = recs*(hk');
    plot(tmp(1),tmp(2),'o','Color',cm(1,:))
    hk = [0 -1];
    tmp = recs*(hk');
    plot(tmp(1),tmp(2),'o','Color',cm(1,:))
    hk = [1 -1];
    tmp = recs*(hk');
    plot(tmp(1),tmp(2),'o','Color',cm(1,:))
    hk = [-1 1];
    tmp = recs*(hk');
    plot(tmp(1),tmp(2),'o','Color',cm(1,:))



    hk = [1 1];
    tmp = recs*(hk');
    radius_2 = norm(tmp);
    plot(tmp(1),tmp(2),'o','Color',cm(2,:))
    hk = -[1 1];
    tmp = recs*(hk');
    plot(tmp(1),tmp(2),'o','Color',cm(2,:))
    hk = [-2 1];
    tmp = recs*(hk');
    plot(tmp(1),tmp(2),'o','Color',cm(2,:))
    hk = [2 -1];
    tmp = recs*(hk');
    plot(tmp(1),tmp(2),'o','Color',cm(2,:))
    hk = [1 -2];
    tmp = recs*(hk');
    plot(tmp(1),tmp(2),'o','Color',cm(2,:))
    hk = [-1 2];
    tmp = recs*(hk');
    plot(tmp(1),tmp(2),'o','Color',cm(2,:))


    plot(0,0,'ok')
    viscircles([0,0],radius_1,'Color',cm(1,:),'LineStyle','-','LineWidth',1)
    viscircles([0,0],radius_2,'Color',cm(2,:),'LineStyle','-','LineWidth',1)

    % axis image
    % grid off

    plot([0,0],[0,radius_1],'Color',cm(1,:),'LineWidth',2,'LineStyle','--')
    plot([0,radius_2],[0,0],'Color',cm(2,:),'LineWidth',2,'LineStyle','--')

    theta_1 = theta_scat(d_calc_latt_meth(1,0));
    theta_2 = theta_scat(d_calc_latt_meth(1,1))


    text(radius_1/20,radius_1/2,'\theta_1')
    text(radius_2/3,radius_2/20,'\theta_2')

    axis equal

    title(['Graphene DP angles for ' num2str(EHT) ' V'])

    


EHTs = [10000 15000 20000 25000 30000];
    
lat_const = 0.246e-9;


lams = getElectronWavelength(EHTs)

% Closed form solution I found somewhere
d_calc = @(h,k)  sqrt((3/4)*lat_const^2/(h^2+h*k+k^2))

d1 = d_calc(1,0)
d2 = d_calc(1,1)

theta_scat = @(d) 2*asin(lams/2/d)

theta_1s = theta_scat(d1)
theta_2s = theta_scat(d2)



tab = array2table([EHTs'/1000 1000*theta_1s' 1000*theta_2s'])
tab.Properties.VariableNames = {'EHT' 'theta_1' 'theta_2'}

CL = 0.01;




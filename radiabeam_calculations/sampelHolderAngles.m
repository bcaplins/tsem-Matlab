%%


Rx = @(ang_rad) [1 0 0
        0 cos(ang_rad) -sin(ang_rad)
        0 sin(ang_rad) cos(ang_rad)];
    
Ry = @(ang_rad) [cos(ang_rad) 0 sin(ang_rad) 
    0 1 0
    -sin(ang_rad) 0 cos(ang_rad)];
    
Rz = @(ang_rad) [cos(ang_rad) -sin(ang_rad) 0
    sin(ang_rad) cos(ang_rad) 0
    0 0 1];


initial_vec = [0 0 1]';

sample_holder_bend_and = -45*pi/180;

rots = linspace(0,60,360);
delta_ang = zeros(size(rots));

for i = 1:length(rots)

    rotation_angle = rots(i)*pi/180;
    tilt_angle = 45*pi/180;

    final_vec = Rx(tilt_angle)*(Rz(rotation_angle)*(Rx(sample_holder_bend_and)*initial_vec));

    delta_ang(i) = acos(dot(initial_vec,final_vec))*180/pi;
end

idxs = find(rots<5 & rots>0);

p = polyfit(rots(idxs),delta_ang(idxs),1);

p(1)




figure(12313423)
clf
hold on
plot(rots,delta_ang)
hold on
plot(rots(idxs),polyval(p,rots(idxs)),'--')



grid on
% ylabel('\Delta\theta wrt Detector')
xlabel('Stage Rotation Angle')

title('For 45\circ Stage Tilt')

set(gca(),'xTick',0:5:60)
% set(gca(),'yTick',0:2:16)


%%


return
% 
% 
% 
% thetas = linspace(0,360, 360);
% eff_thetas = zeros(size(thetas));
% 
% Det = [1 1 0]'
% Det = Det/norm(Det)
% 
% Samp = [1 -1 0]'
% Samp = Samp/norm(Samp)
% 
% for i=1:length(thetas)
%     theta = thetas(i)*pi/180;
%     rot = [cos(theta) 0 sin(theta)
%             0 1 0
%             -sin(theta) 0 cos(theta)]
%     nSamp = rot*Samp
% %     acos(dot(Det,nSamp))*180/pi-90;
%     eff_thetas(i) = acos(dot(Det,nSamp))*180/pi-90;
% 
% end
% 
% 
% 
% 
% figure(123123)
% clf
% hold on
% plot(thetas,eff_thetas)
% 
% grid on
% ylabel('\Delta\theta wrt Detector')
% xlabel('Stage Rotation Angle')
% 
% title('For 45\circ Stage Tilt')
% 
% % set(gca(),'xTick',0:5:60)
% % set(gca(),'yTick',0:2:16)

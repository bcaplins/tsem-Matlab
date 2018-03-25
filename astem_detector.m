

rs = [.25 1.5 5 8]

wds = linspace(10,3,2^7);

scat = atan(rs./wds')


plot(wds,scat)

% grid on

xlabel('CL (mm)')
ylabel('angle (radians)')





% 
% 
% phi = 0:4:60;
% N_SCANS = numel(phi);
% TIME_PER_SCAN = 60;
% time_min = N_SCANS*TIME_PER_SCAN/60
% 
% 
% g = @(x,x0,s) exp(-(x-x0).^2/(2*s^2))
% 
% d1 = g(phi,3,2.5)+g(phi,63,2.5);
% d2 = g(phi,33,2.5);
% 
% figure(31231)
% clf
% hold on
% plot(phi,d1,'-o')
% plot(phi,d2,'-o')
% 
% xlabel('\phi (degrees)')
% ylabel('DF intensity')
% title('Sampling every 5 degrees')
% 


beam_volt = 30000; % eV
lattice_constant = 0.246; % nm
semi_angle  = 2e-3;%(1/2)*(1/3)*5.8e-3; % radians




bragg_angle = @(beam_volt,lattice_constant) asin(1e9*getElectronWavelength(beam_volt)./(2*lattice_constant)) % radians



figure(1)
clf, hold on
plot_circle([0 0],semi_angle);

M = 5;
for i=-M:1:M
    for j=-M:1:M
        plot_circle((2*bragg_angle(beam_volt,lattice_constant))*[i j],semi_angle);
    end
end

axis square
axis equal



figure(1323), clf, hold on
beam_volts = logspace(log10(1000),log10(40000),100);
plot([min(beam_volts) max(beam_volts)]/1000,2*[1 1],'--')

clear leg;
leg{1} = 'arbitrary limit';

SAs = [1e-3 2e-3 3e-3 4e-3 6e-3 10e-3 15e-3];
for semi_angle = SAs

    diff_angs = 2*bragg_angle(beam_volts,lattice_constant);
    spot_widths = 2*semi_angle*ones(size(diff_angs));

    plot(beam_volts/1000,diff_angs./spot_widths)
    leg{length(leg)+1} = [num2str(semi_angle) ' mRad'];
end
legend(leg)

xlabel('energy (kV)')
ylabel('d_{separation} / d_{spot}')

title(['lattice constant = ' num2str(lattice_constant) ' nm'])

ylim([0 10])
xlim([0 30])
grid on






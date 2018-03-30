    function elec_wl =  getElectronWavelength(volts)
% Returns electron wavelength in meters

m_e = 9.10938356e-31;%kg
c = 2.99792458e8; %m/s
q = 1.60217662e-19; %coulombs
h = 6.62607004e-34; %m^2 kg/s

elec_wl = (h/sqrt(2*m_e*q*volts))*(1/sqrt(1+q*volts/(2*m_e*c*c)));

end

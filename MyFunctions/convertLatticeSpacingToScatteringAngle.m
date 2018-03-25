function scattering_angle = convertLatticeSpacingToScatteringAngle(a_lat,EHT)

elec_wl = getElectronWavelength(EHT);

% Twice bragg angle
scattering_angle = 2*asin(elec_wl./(2*a_lat)); % radians


EHT = 30000
MSD = 0.006e-20
ALPHA = 0.22

M = (8*pi^2)*((sin(ALPHA/2)^2)/(getElectronWavelength(EHT)^2))*MSD

exp(-2*M)


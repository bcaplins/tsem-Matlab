clc
clear all
close all

ePerC = 6.24e18;

% Noise factor probably due to transimpedance amp??? 
% or incorrect assumptions?
NF = 1.00;

FUDGEY_LOSS = 1;

% Extra gain factor needed to match experiment
FUDGEY_GAIN = 1.65;


lambda = 550; % nm
top_reflective_coating = 1.9*1.0;
first_mirror_ref = 1.; % 0.85 for UV
aper = 0.9*25.4;%0.9*25.4; % 7.5 mm for aperture,  0.9*25.4 mm for no aperture 
Resp = .16;0.043; % 0.043 for 550 nm -01, 0.13 for 400 nm -210 % assum
n_yag = 1.83;
fracOfSignalCollected = 0.004; % basically 1.0 for brightfield


joulePerPhoton = (1240/lambda)*1.6e-19

% YAGyieldPereV = (3/4)*35000e-6;  % photons per eV  Another paper saud more like 17000
YAGyieldPereV = 30000e-6;  % photons per eV  Another paper saud more like 17000
beamEnergyDeposited = 30*1000*0.84; % eV


beamCurrent = 269e-12; % amps

% Calculated the solid angle subtended
f = 150; % mm
external_acceptance_semiangle = atan((aper/2)/f)
% external_acceptance_semiangle = 12*pi/180
external_acceptance_semiangle*180/pi

% Account for refractive index change in solid angle calculation
n_air = 1;

internal_acceptance_semiangle = asin(n_air*sin(external_acceptance_semiangle )/n_yag)
internal_solid_angle = 2*pi*(1-cos(internal_acceptance_semiangle))

fraction_of_photons_collected = internal_solid_angle/(4*pi)



dmd_fill_factor = 0.92;
dmd_reflectivity = 0.88;
dmd_transmission = 0.97^2;
dmd_diffraction_eff = 0.86;

dmd_efficiency = dmd_fill_factor*dmd_reflectivity*dmd_transmission*dmd_diffraction_eff;
glass_interface_loss = 0.96^4; % Assume two for vacuum break and two for PMT
diffuser_loss = 0.85;

photonCouplingEfficiency = top_reflective_coating*first_mirror_ref...
    *fraction_of_photons_collected*dmd_efficiency*glass_interface_loss*diffuser_loss*FUDGEY_LOSS


elPerSec = beamCurrent*ePerC

phPerEl = beamEnergyDeposited*YAGyieldPereV

phPerSec = phPerEl*elPerSec

phPerSecThroughLens = phPerSec*photonCouplingEfficiency

phPerSecOnDetector = phPerSecThroughLens*fracOfSignalCollected

powerOnDetector = phPerSecOnDetector*joulePerPhoton

%%%

% Assume 10 sec per image for 256*256
pixelPerImage = 1024*768/2/2
% secPerImage = 80*(1024*768/80/20000)
secPerImage = 80

pixelPerSec = pixelPerImage/secPerImage

% Beam dose (C/cm^2) assuming 1nm square
beamDose = beamCurrent/pixelPerSec/1e-14


% H10722-01
% RmaxDivR550 = 10/2;

% powerOnDetector = powerOnDetector/100;



M = FUDGEY_GAIN*2e6;
transImpGain = 1e6 % volt/amp

outputV = powerOnDetector*Resp*M*transImpGain
outputA = powerOnDetector*Resp*M

darkCurrent = 10e-9 % amps
darkV = darkCurrent*transImpGain

QE = Resp*1240/lambda

numPhMeasuredOnPMTperPix = phPerSecOnDetector*QE/pixelPerSec

StoN_background = outputV/darkV
StoN_Vrms = (outputV-darkV)/0.002
% StoN_count = numPhMeasuredOnPMTperPix/sqrt(numPhMeasuredOnPMTperPix)/NF


DELTA = 6;
F = DELTA/(DELTA-1);

StoN_analog_count = (powerOnDetector*Resp)/...
    sqrt( 2 * (1/ePerC) * (powerOnDetector*Resp+2*darkCurrent/M) * pixelPerSec*F)/NF

% 1/StoN_analog_count

phDetPerEl = phPerEl*photonCouplingEfficiency*QE










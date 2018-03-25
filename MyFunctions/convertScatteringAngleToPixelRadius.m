function pixel_radius = convertScatteringAngleToPixelRadius(scattering_angle,DET_WD,SAMP_WD,MM_PER_PIX)

% Calculate camera length
CL = DET_WD-SAMP_WD;

if(nargin<4)
    % I think this is correct.... for calibrations done at 100 mag
    MM_PER_PIX = 2.826855455*1e-3;
end

pixel_radius = (CL/MM_PER_PIX)*tan(scattering_angle);

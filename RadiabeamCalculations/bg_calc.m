% source strength -- maybe photons/sec, arbitrary
b = 1;

% focal length of lens (mm)
f = 150;

% distance from lens to ITO window and back (mm)
d_shift = 2*43;

% radius of lens (mm)
lens_radius = 25.4/2;

% solid angle of captured from point source at yag
SA1 = 2*pi*(1-cos(atan(lens_radius/f)))

% radius and area of direct beam on yag (mm)
source_radius = 12*tan(0.003);
source_area = pi*source_radius*source_radius;

% solid angle of virtual source over unit of source area
SA2 = 2*pi*(1-cos(atan(source_radius/d_shift)))

% fraction of photons reflected by window
frac = 0.2;

% intensity on detector for real reflected sources
I1 = (1-frac)*b*SA1/4/pi/source_area
I2 = frac*b*SA2/4/pi/source_area

I2/I1

radius_reflected_spot = d_shift*(lens_radius/(f+d_shift));

total_I1 = I1*source_area
total_I2 = I2*(pi*radius_reflected_spot^2)

total_I2/total_I1

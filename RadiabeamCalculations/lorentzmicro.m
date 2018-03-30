e = 1.60217662e-19; % charge on elec
h = 6.62607004e-34; % plancks
lam =  1.2205e-11; % At 10 keV
t = 30e-9; % nanometers
B0 = 2.15; % tesla (iron)

beta = e*B0*lam*t/h

disc = 2e-3


x = linspace(-2,2,2^12);
y = linspace(-2,2,2^12);

[X Y] = meshgrid(x,y);

R = sqrt(X.^2 + Y.^2);


idxs = find(R<=1);
tot = numel(idxs);

idxs = find(R<=1 & X>=0);
det0 = numel(idxs)/tot

idxs = find(R<=1 & X>=.1);
det1 = numel(idxs)/tot



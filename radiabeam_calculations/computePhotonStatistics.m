






th_cut = 0.0824;
th_cut = pi

l_cut = sqrt(4*(1-cos(th_cut/2)^2));

N_PH = 700;
N_TRIALS = 1000;
vs = randDir(1000*N);
delvs = vs - [1 0 0];

nrms = sqrt(delvs(:,1).^2+delvs(:,2).^2+delvs(:,3).^2);

isDet = (nrms<=l_cut);

numDet = reshape(isDet,N_TRIALS,N_PH);

numDet = sum(numDet,2);

mean(numDet)
sqrt(mean(numDet))
std(numDet)







function vs = randDir(N)

    rns = randn(N,3);
    nrms = sqrt(rns(:,1).^2+rns(:,2).^2+rns(:,3).^2);
    
    vs = rns./nrms;
    
end
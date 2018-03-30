function dis = calculateAngleDistWRTplane(dat,N_BINS)

EDGES = linspace(-0.001,pi,N_BINS+1);
DELT = EDGES(2)-EDGES(1);

N_SCAN_PTS = length(dat);
N_TRAJ = length(dat{1});

%%% Analyze data
dis(N_SCAN_PTS) = struct();

for sc_idx=1:N_SCAN_PTS
    thetas = zeros(N_TRAJ,1);
    phis = zeros(N_TRAJ,1);
    radii = zeros(N_TRAJ,1);
    keV = zeros(N_TRAJ,1);
    
    for i=1:N_TRAJ
        P = dat{sc_idx}(i,1:3);
        Rv = dat{sc_idx}(i,4:6);
        % Eliminate y dependence.. i.e. project onto xz plane
        Rv(2) = 0;
        %theta = atan2( norm(cross([0 0 1], Rv)), dot ([0 0 1], Rv));
        theta = acos(Rv(3)/norm(Rv));
        phi = atan2(Rv(2),Rv(1));
        
        
        thetas(i) = theta;
        phis(i) = phi;
        radii(i) = norm(P(1:2));
        keV(i) = dat{sc_idx}(i,7);
    end

    dis(sc_idx).thetas = thetas;
    dis(sc_idx).phis = phis;
    dis(sc_idx).radii = radii;
    dis(sc_idx).keV = keV;
    

    

    Q1_idxs = find(phis>=0 & phis < pi/2);
	Q2_idxs = find(phis>=pi/2 & phis <= pi);
    Q3_idxs = find(phis>=-pi & phis < -pi/2);
    Q4_idxs = find(phis>=-pi/2 & phis < 0);
       
    N1 = histcounts(thetas(Q1_idxs),EDGES);
    N2 = histcounts(thetas(Q2_idxs),EDGES);
    N3 = histcounts(thetas(Q3_idxs),EDGES);
    N4 = histcounts(thetas(Q4_idxs),EDGES);
    
    CENTERS = (EDGES(1:(end-1))+EDGES(2:end))/2;

    dis(sc_idx).x = CENTERS;
    
    N = N1+N2+N3+N4;
    
    Ntop = N1+N2;
    Nbottom = N3+N4;
    Nleft = N2+N3;
    Nright = N1+N4;
    
    
    dis(sc_idx).hTotal = N;
    dis(sc_idx).hTop = Ntop;
    dis(sc_idx).hBottom = Nbottom;
    dis(sc_idx).hLeft = Nleft;
    dis(sc_idx).hRight = Nright;
    
    dis(sc_idx).pTotal = N/sum(N)/DELT;
    dis(sc_idx).pTop = Ntop/sum(Ntop)/DELT;
    dis(sc_idx).pBottom = Nbottom/sum(Nbottom)/DELT;
    dis(sc_idx).pLeft = Nleft/sum(Nleft)/DELT;
    dis(sc_idx).pRight = Nright/sum(Nright)/DELT;
    
    
    
end


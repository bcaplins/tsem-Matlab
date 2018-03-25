



g001_1 = [-2 0 0];
g001_2 = [0 2 0];

g011_1 = [-2 0 0];
g011_2 = [-1 1 -1];

g111_1 = [-2 0 -2];
g111_2 = [0 2 -2];

N = 3;

lat_001 = zeros(2*N+1,1);
idx = 0;
for i=-N:N
    for j=-N:N
        idx = idx+1;
        g = i*g001_1+j*g001_2;
        lat_001(idx) = dot(g,g);
    end 
end
lat_001 = tabulate(lat_001);






lat_011 = zeros(2*N+1,1);

idx = 0;
for i=-N:N
    for j=-N:N
        idx = idx+1;
        g = i*g011_1+j*g011_2;
        lat_011(idx) = dot(g,g);
    end 
end
lat_011 = tabulate(lat_011);





lat_111 = zeros(2*N+1,1);

idx = 0;
for i=-N:N
    for j=-N:N
        idx = idx+1;
        g = i*g111_1+j*g111_2;
        lat_111(idx) = dot(g,g);
    end 
end
lat_111 = tabulate(lat_111);


lat_011'
lat_111'
lat_001'

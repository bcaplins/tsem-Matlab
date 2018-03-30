function [dcs ann_dcs] = loadNistDCS(element,EHT_kV)

    fn = [element num2str(EHT_kV) 'keV.H64'];
    

    N = 606;

    fid = fopen(fn);
    X = textscan(fid,'%f%f',N,'Headerlines',12);
    fclose(fid);

    a02 = 2.8002852e-21;

    x = X{1}*pi/180;
    y = X{2}*a02;

    dcs = [x y];

    ann_dcs = [x 2*pi*sin(x).*y];

end
function cs = getElasticCSfromDSC(element,EHT_kV)


    dcs = loadNistDCS(element,EHT_kV);
    
    cs = trapz(dcs(:,1),2*pi*sin(dcs(:,1)).*dcs(:,2));

end
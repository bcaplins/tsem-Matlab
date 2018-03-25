function emfp = getElasticMFPfromDSC(element,EHT_kV)

    Na = 6.022e23;

    if(element == 'Al')   
        ma = 27; % gram/mol
        rho = 2.7 *1e6;% gram / m^3
    elseif(element == 'C')
        ma = 12.011;
        rho = 2.26*1e6;
    elseif(element == 'Si')
        ma = 28.1;
        rho = 2.29*1e6;
    elseif(element == 'Au')
        ma = 197;
        rho = 19.32*1e6;
    elseif(element == 'Ge')
        ma = 72.6;
        rho = 5.323*1e6;
    elseif(element == 'Sn')
        ma = 118.7;
        rho = 7.31*1e6;
    elseif(element == 'Pb')
        ma = 207.2;
        rho = 11.34*1e6;
    else
        error('Add element to function')
    end

    cs = getElasticCSfromDSC(element,EHT_kV);
    
    N = Na*rho/ma;
    emfp = 1/(N*cs);  
    
end

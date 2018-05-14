function y = wrappedGauss(theta,mu,sig)
    pre = 1/(sig*sqrt(2*pi));
    
    tot = exp(-(theta-mu).^2/(2*sig*sig));
    N_max = 4;
    for k = 1:N_max
        s1 = exp(-(theta-mu+2*pi*k).^2/(2*sig*sig));
        s2 = exp(-(theta-mu-2*pi*k).^2/(2*sig*sig));
        tot = tot+s1+s2;
    end
    y = tot*pre;

end


function [f P1] = computeFFTspectrum(X)



    T = mean(diff(X(:,1)))
    Fs = 1/T
   
    L = length(X);
    if(rem(L,2)==1)
        L = L-1;
        X(end,:) = [];
    end
%     t = (0:L-1)*T;
    fft_dat = fft(X(:,2));
    
    P2 = abs(fft_dat/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = Fs*(0:(L/2))/L;
%     figure(1)
%     clf 
%     hold on
%     plot(f,P1) 
%     ax = gca;
%     ax.YScale = 'log';
%     ax.XScale = 'log';
%     title('Single-Sided Amplitude Spectrum of X(t)')
%     xlabel('f (Hz)')
%     ylabel('|P1(f)|')
%     pause()
%     

return






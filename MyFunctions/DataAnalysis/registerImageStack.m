% function ndat = registerImageStack(dat)
% %UNTITLED3 Summary of this function goes here
% %   Detailed explanation goes here
%     
% N_CHAN = size(dat,3);
% 
% shiftX = zeros(N_CHAN,1);
% shiftY = zeros(N_CHAN,1);
% 
% fft2s = zeros(size(dat));
% 
% for i=1:N_CHAN
%     fft2s(:,:,i) = fft2(dat(:,:,i));
% end
% 
% % Upsample factor
% USAMP = 1;
% 
% ct = 0;
% for i=2:N_CHAN
%         ct = ct+1;
%         output  = dftregistration(fft2s(:,:,1),fft2s(:,:,i),USAMP);
%         shiftY(i) = output(3);
%         shiftX(i) = output(4);
%         frac = 100*ct/(N_CHAN-1);
%         fprintf('%d percent complete registering\n',round(frac))
% end
% % shiftX = shiftX-shiftX';
% % shiftY = shiftY-shiftY';
% 
% % figure(2321)
% % clf
% % subplot(1,2,1)
% % h = heatmap(shiftX);
% % h.GridVisible = 'off'
% % 
% % subplot(1,2,2)
% % h = heatmap(shiftY);
% % h.GridVisible = 'off'
% % 
% % colorcet('D1')
% 
% % dX = sum(shiftX)/N_CHAN;
% % dY = sum(shiftY)/N_CHAN;
% 
% dX = shiftX;
% dY = shiftY;
% 
% V = imref2d(size(dat(:,:,1)));
% 
% ndat = zeros(size(dat));
% 
% for i=1:N_CHAN
%     tform = affine2d([1 0 0; 0 1 0; (dX(i)) (dY(i)) 1]);
%     ndat(:,:,i) = imwarp(dat(:,:,i),tform,'OutputView',V,'FillValues',NaN);
%     fprintf('%d percent complete warping\n',round(100*i/N_CHAN))
% end
% %     
% % figure(1321)
% % clf
% % for i=1:N_CHAN 
% %     imshow(ndat(:,:,i));
% %     pause
% % end
% 
% end
% 
% 
% 


function ndat = registerImageStack(dat)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    
N_CHAN = size(dat,3);

shiftX = zeros(N_CHAN);
shiftY = zeros(N_CHAN);

fft2s = zeros(size(dat));

for i=1:N_CHAN
    fft2s(:,:,i) = fft2(dat(:,:,i));
end

% Upsample factor
USAMP = 1;

ct = 0;
for i=1:N_CHAN
    for j=(i+1):N_CHAN
        ct = ct+1;
        output  = dftregistration(fft2s(:,:,i),fft2s(:,:,j),USAMP);
        shiftY(i,j) = output(3);
        shiftX(i,j) = output(4);
        frac = 100*ct/(N_CHAN*(N_CHAN-1)/2);
        fprintf('%d percent complete registering\n',round(frac))
    end
end
shiftX = shiftX-shiftX';
shiftY = shiftY-shiftY';

% figure(2321)
% clf
% subplot(1,2,1)
% h = heatmap(shiftX);
% h.GridVisible = 'off'
% 
% subplot(1,2,2)
% h = heatmap(shiftY);
% h.GridVisible = 'off'
% 
% colorcet('D1')

dX = sum(shiftX)/N_CHAN;
dY = sum(shiftY)/N_CHAN;

V = imref2d(size(dat(:,:,1)));

ndat = zeros(size(dat));

for i=1:N_CHAN
    tform = affine2d([1 0 0; 0 1 0; (dX(i)) (dY(i)) 1]);
    ndat(:,:,i) = imwarp(dat(:,:,i),tform,'OutputView',V,'FillValues',NaN);
    fprintf('%d percent complete warping\n',round(100*i/N_CHAN))
end
%     
% figure(1321)
% clf
% for i=1:N_CHAN 
%     imshow(ndat(:,:,i));
%     pause
% end

end





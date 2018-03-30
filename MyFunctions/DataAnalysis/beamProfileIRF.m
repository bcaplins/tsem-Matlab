function [x ys] = beamProfileIRF(x0s,N_seg,d)
    
    ys = zeros(length(x0s),N_seg);
    
    
    for i=1:length(x0s)
        [xx yy] = singleIRF(x0s(i),N_seg,d);
        
        if(i==1)
            x = xx;
        end
        ys(i,:) = yy(:);
    end
    

end




function [xs ys] = singleIRF(x0,N_seg,d)

persistent xq;
persistent dxq;
persistent yq;
if isempty(xq)
    N = 2^16;        
    xq = linspace(-30,30, N);
    dxq = xq(2)-xq(1);
    yq = zeros(size(xq));
    idxs = find(xq>=-d/2 & xq<=d/2);
    yq(idxs) = 2*sqrt((d/2)^2-xq(idxs).^2)*dxq;
    yq = yq./(d*d*pi/4);

    xq = linspace(0,60, N);
    yq = circshift(yq,[0 N/2]);
    end

xs = 0:60/N_seg:60;

delx = 30-x0;

delx_idx = round(delx./dxq);

yqq = circshift(yq,-delx_idx);

ys = zeros(size(xs));

for i=1:length(ys)-1;
    ys(i) = sum(yqq(xq>=xs(i) & xq<xs(i+1)));
end

xs = xs(1:end-1);
ys = ys(1:end-1);




end
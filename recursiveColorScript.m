clear all
close all

im_size = 512;
d2 = im_size/2;

sc = 100;

% im(1:d2,1:d2) = poisson(sc*0.8,d2,d2);
% im(d2+(1:d2),1:d2) = poisson(sc*0.75,d2,d2);
% im((1:d2)+d2,(1:d2)+d2) = poisson(sc*0.6,d2,d2);
% im(1:d2,(1:d2)+d2) = poisson(sc*0.4,d2,d2);


im = zeros(im_size,im_size,3);
im(1:d2,1:d2,1) = poisson(sc*0.8,d2,d2);
im(d2+(1:d2),1:d2,1) = poisson(sc*0.75,d2,d2);
im((1:d2)+d2,(1:d2)+d2,1) = poisson(sc*0.6,d2,d2);
im(1:d2,(1:d2)+d2,1) = poisson(sc*0.4,d2,d2);

im(1:d2,1:d2,2) = poisson(sc*0.8,d2,d2);
im(d2+(1:d2),1:d2,2) = poisson(sc*0.75,d2,d2);
im((1:d2)+d2,(1:d2)+d2,2) = poisson(sc*0.6,d2,d2);
im(1:d2,(1:d2)+d2,2) = poisson(sc*0.4,d2,d2);


im(1:d2,1:d2,3) = poisson(sc*0.8,d2,d2);
im(d2+(1:d2),1:d2,3) = poisson(sc*0.75,d2,d2);
im((1:d2)+d2,(1:d2)+d2,3) = poisson(sc*0.6,d2,d2);
im(1:d2,(1:d2)+d2,3) = poisson(sc*0.4,d2,d2);

% im(d2/2+(1:d2),(1:d2)+d2/2) = im(d2/2+(1:d2),(1:d2)+d2/2)*.75;

% im = im.*(randn(size(im))/10+1);
% im = im./max(im(:));

% im = imread('D:\Users\clifford\Downloads\Untitled.bmp');
% im = mean(im,3)/255;
% 
% sc = 1;


% im = repmat(im,[1 1 3]);
 
% k = ones(3);
% k = k/sum(sum(k));
% im = conv2(im,k,'Same');
% 

num_levels = 6;



rim = recursiveColor(im,num_levels);

figure(1)
clf
imshow(im./max(im(:)))

figure(2)
clf
imshow(rim./max(rim(:)))

return


ims = cell(num_levels,1);

ims{1} = im;

   figure(12)
    clf
    imshow(ims{1}/sc)
%     pause()


for l_idx=2:num_levels
    sz = size(ims{l_idx-1});
    new_sz = sz/2;
    
    ims{l_idx} = zeros(new_sz);
    for i=1:new_sz(1)
        for j=1:new_sz(2)
            i_idxs = [2*(i-1)+1 2*(i-1)+2];
            j_idxs = [2*(j-1)+1 2*(j-1)+2];
            ims{l_idx}(i,j) = sum(sum(ims{l_idx-1}(i_idxs,j_idxs)))/4;
        end
    end
%     figure(12)
%     clf
%     imshow(ims{l_idx}/sc)
%     pause()
end





rims = cell(size(ims));
rims{end} = ims{end};

for l_idx=(num_levels-1):-1:1
    prev_sz = size(ims{l_idx+1});
    curr_sz = 2*prev_sz;
    rims{l_idx} = zeros(curr_sz);
    
    for i=1:curr_sz(1)
        for j=1:curr_sz(2)
            i_lower = floor((i-1)/2)+1;
            j_lower = floor((j-1)/2)+1;
            
            is_lower = [max(i_lower-1,1) min(i_lower+1,prev_sz(1))];
            js_lower = [max(j_lower-1,1) min(j_lower+1,prev_sz(2))];
            
            curr_val = ims{l_idx}(i,j);
            pos_vals = rims{l_idx+1}(is_lower,js_lower);
            
            [dummy idx] = min((curr_val-pos_vals(:)).^2);
            rims{l_idx}(i,j) = pos_vals(idx);
            
        end
    end
%     figure(1234)
%     clf
%     imshow(rims{l_idx}/sc)
%     pause()
end

figure(123)
clf
subplot(2,1,1)
% histogram(ims{1}(:),0:2*sc)
histogram(ims{1}(:),64)
xlim([0 2*sc])
subplot(2,1,2)
histogram(rims{1}(:),64)
xlim([0 2*sc])



fin = zeros(size(rims{1}));
breaks = [0 30 50 65 77 100];

ct = -1;
for i=2:length(breaks)
    ct = ct+1;
    fin(rims{1}>=breaks(i-1) & rims{1}<breaks(i)) = ct;
end

   figure(12346)
    clf
    imshow(fin/ct)






function [fimg ims rims] = recursiveColor(img,num_levels)

N_DEPTH = size(img,3);

im_size = size(img);

if(sum(rem(im_size(1:2),2^(num_levels-1)))~=0)
    error('image must be divisible by 2^(num_levels-1)')
end

ims = cell(num_levels,1);
ims{1} = img;

disp('binning level...')
for l_idx=2:num_levels
    tic;
    sz = size(ims{l_idx-1});
    new_sz = [sz(1)/2 sz(2)/2 N_DEPTH];
    
    ims{l_idx} = zeros(new_sz);
    for i=1:new_sz(1)
        for j=1:new_sz(2)
            i_idxs = [2*(i-1)+1 2*(i-1)+2];
            j_idxs = [2*(j-1)+1 2*(j-1)+2];
            ims{l_idx}(i,j,:) = sum(sum(ims{l_idx-1}(i_idxs,j_idxs,:),1),2)/4;
        end
    end
    t = toc;
    fprintf('level %d took %d seconds; level %d est to take %d seconds\n',...
        l_idx,round(t),l_idx+1,round(t/4))
end


sqdist = @(A,B) sum((repmat(A,size(B,1),1)-B).^2,2);


disp('unbinning level...')
rims = cell(size(ims));
rims{end} = ims{end};
for l_idx=(num_levels-1):-1:1
    tic;
    prev_sz = size(ims{l_idx+1});
    curr_sz = [2*prev_sz(1) 2*prev_sz(2) N_DEPTH];
    rims{l_idx} = zeros(curr_sz);
    
    for i=1:curr_sz(1)
        for j=1:curr_sz(2)
            i_lower = floor((i-1)/2)+1;
            j_lower = floor((j-1)/2)+1;
            
            is_lower = [max(i_lower-1,1):min(i_lower+1,prev_sz(1))];
            js_lower = [max(j_lower-1,1):min(j_lower+1,prev_sz(2))];
            
            curr_val = reshape(ims{l_idx}(i,j,:),1,N_DEPTH);
            tmp = rims{l_idx+1}(is_lower,js_lower,:);
            pos_vals = reshape(tmp,numel(tmp)/N_DEPTH,N_DEPTH);
            
            
            [dummy idx] = min(sqdist(curr_val,pos_vals));
%             [dummy idx] = min(pdist2(curr_val,pos_vals));
            rims{l_idx}(i,j,:) = pos_vals(idx,:);
            
        end
    end
    t = toc;
%     figure(1234)
%     clf
%     imshow(rims{l_idx}/sc)
%     pause()
    fprintf('level %d took %d seconds; level %d est to take %d seconds\n',...
        l_idx,round(t),l_idx-1,round(4*t))
end

fimg = rims{1};


% figure(123)
% clf
% subplot(2,1,1)
% % histogram(ims{1}(:),0:2*sc)
% histogram(ims{1}(:),64)
% xlim([0 2*sc])
% subplot(2,1,2)
% histogram(rims{1}(:),64)
% xlim([0 2*sc])
% 
% 
% 
% fin = zeros(size(rims{1}));
% breaks = [0 30 50 65 77 100];
% 
% ct = -1;
% for i=2:length(breaks)
%     ct = ct+1;
%     fin(rims{1}>=breaks(i-1) & rims{1}<breaks(i)) = ct;
% end
% 
%    figure(12346)
%     clf
%     imshow(fin/ct)
% 
% 



end
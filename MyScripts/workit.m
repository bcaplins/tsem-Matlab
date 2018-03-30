clear all

% pre = 'graph_series_12spot_v1_'
% pre = 'graph_series_v1_'
pre = 'graph_series_v1_'
post = '.tif'

clear fns;


N_seg = 20;
roi_i = 1:640;
roi_j = 1:1024;

dat = zeros(length(roi_i),length(roi_j),N_seg);

se2 = double(imread([pre sprintf('%0.2d',0) post]))/255;
se2 = se2(roi_i,roi_j); 
se2orig = se2;


for i=1:N_seg
    
    fns{i} = [pre sprintf('%0.2d',i) post];
    im = double(imread(fns{i}))/255;
%     figure(3123)
%     clf
    dat(:,:,i) = im(roi_i,roi_j)*8;
end


% ref = dat(:,:,1);
% ndat = zeros(size(dat));
% ndat(:,:,1) = ref(:,:);
% 
% for i=2:N_seg
%    
%     [opt met] = imregconfig('Multimodal')
%     
%     moving = dat(:,:,i);
%     reg = imregister(moving,ref,'translation',opt,met);
% 
%         
%     ndat(:,:,i) = reg(:,:);
% 
% end

% 
% for i=1:N_seg
%      figure(43214)
%      clf
%      imshow(dat(:,:,i))
%      pause
% end


N_block = 8;
sz = size(dat);
red_dat = zeros(sz(1)/N_block,sz(2)/N_block,sz(3));


for i=1:max(roi_i)/N_block
    for j=1:max(roi_j)/N_block
        i_idxs = (i*N_block-N_block+1):(i*N_block);
        j_idxs = (j*N_block-N_block+1):(j*N_block);
        tmp = sum(sum(se2(i_idxs,j_idxs),2),1)/N_block/N_block;
        
        se22(i,j) = tmp(:);
        
    end
end    
se2= se22;


for i=1:max(roi_i)/N_block
    for j=1:max(roi_j)/N_block
        i_idxs = (i*N_block-N_block+1):(i*N_block);
        j_idxs = (j*N_block-N_block+1):(j*N_block);
        tmp = sum(sum(dat(i_idxs,j_idxs,:),2),1)/N_block/N_block;
        
        red_dat(i,j,:) = tmp(:);
        
    end
end    

red_dat = red_dat(2:end-1,2:end-1,:);

se2 = se2(2:end-1,2:end-1);

% 
% for i=1:N_seg
%      figure(43214)
%      clf
%      imshow(red_dat(:,:,i),'InitialMagnification',500)
% %      imshowpair(red_dat(:,:,i),red_dat(:,:,1))
%      pause
% end


% figure(123123)
% clf
% hold on
thetas = 0:60/N_seg:60;
thetas = thetas(1:end-1);

sz = size(red_dat);
means = zeros(sz(1),sz(2));
maxang = zeros(sz(1),sz(2));
maxval = zeros(sz(1),sz(2));

N_REFS = 60;
refs = zeros(N_REFS,N_seg);
x0s = 0:60/N_REFS:60;
x0s = x0s(1:end-1);
for i=1:N_REFS
    [xx yy] = fit_func(x0s(i),N_seg,6);
    refs(i,:) = yy(:);
end

% for i=1:N_REFS
%     plot(xx,refs(i,:))
%     pause
% end


ref = refs(3,:);
for i=1:size(red_dat,1)
    for j=1:size(red_dat,2)
        y = red_dat(i,j,:);
    
        tmp = sort(y);
        baselin = mean(tmp(1:ceil(N_seg*.6)));
        means(i,j) = mean(y);
        y = y(:)'-baselin;
        maxy = max(y);
        y = y./maxy;
        
        
%         mle(y)
     
        metr = sum(y.*refs,2);
        
%         figure(12321)
%         clf
%         plot(xx,y*maxy+baselin)
%         ylim([0 1])
%         pause
%         
        [dum idx] = max(metr);
        maxang(i,j) = x0s(idx);
        maxval(i,j) = dum*maxy;
        
%         
        

%         xc = cconv(ref,y(:),length(ref));
%         [dum, idx] = max(xc);
%         maxs(i,j) = thetas(idx);
% %         
%         [dum, idx] = max(y(:));
        
        
        
        

    end
    [i,j]
end

% isGood = (means<=0.42 & means>=0.35);
isGood = (means<=0.375 & means>=0.31);
% isGood = (means<=0.55 & means>=0.42);
% isGood = means>-inf;







figure(421412)
clf


% image(se2)

% imshow(maxs)
% hold on
f = image(maxang)
% f = image(maxval)
f.AlphaData = isGood;
caxis([0 60])
colormap(hsv)
colorbar()
axis image
ax = gca
ax.Visible = 'off'

cm = hsv;
c_idxs = f.CData+1;

c_dat = zeros([size(maxang) 3]);

al = .7;
for i=1:size(c_dat,1)
    for j=1:size(c_dat,2)
        if(isGood(i,j))
            c_dat(i,j,:) = (al.*cm(c_idxs(i,j)+1,:) + (1-al)*se2(i,j).*[1 1 1])./(al+1*(1-al));
        else
            c_dat(i,j,:) = se2(i,j).*[1 1 1];
        end
%         c_dat(i,j,:) = se2(i,j).*cm(c_idxs(i,j)+1,:);
    end
end

se2orig = repmat(se2orig,[1 1 3]);

figure(13412)
clf
% image([0 1],[0 1],c_dat)

asrat = size(se2orig,1)/size(se2orig,2)

image([0 1]/asrat,[0 1],se2orig)

hold on
image([0 1]/asrat,1+[0 1],c_dat)

axis image
% imshowpair(se2,c_dat,'montage')
% 
ax = gca
ax.Visible = 'off'

figure(41423)
clf
hdat = maxang;
hdat(isGood~=1) = [];
histogram(hdat,N_REFS)
xlabel('angle of graphene lattice')
ylabel('# of pixels')


% 
% figure
% imshow(,'InitialMagnification',1000)





maxang(isGood~=1) = 0;
% 
% i_idxs = 1:size(maxang,1);
% j_idxs = 1:size(maxang,2);
% [I_idxs, J_idxs] = meshgrid(j_idxs,i_idxs);
% 
% 
% fulldat  = [0*I_idxs(:) 0*J_idxs(:) maxang(:)*100];
% size(fulldat)

fulldat = reshape(red_dat,size(red_dat,1)*size(red_dat,2),20);
% ful

fulldat(isGood(:)~=1,:) = NaN;


N_CLUST = 3;
[cluster_idx, cluster_center] = kmeans(fulldat,N_CLUST,'distance','sqeuclid', ...
                                      'Replicates',3);


pixel_labels = reshape(cluster_idx,size(red_dat,1),size(red_dat,2));
% pixel_labels = reshape(cluster_idx,size(maxang,1),size(maxang,2));





figure(52345324)
imshow(pixel_labels+1,1+[1 N_CLUST]), title('image labeled by cluster index');
% pause


res = pixel_labels;


for q=1:2
    nres = zeros(size(res));
    for i=2:size(res,1)-1
        for j=2:size(res,2)-1
            m = res(i-1:i+1,j-1:j+1);
            curr = m(5);
            m(5) = [];
            [mo fr] = mode(m);
            if(fr>=6)
                nres(i,j) = mo;
            else
                nres(i,j) = curr;
            end
        end
    end
    res = nres;
    
    figure(52345325)
    imshow(nres,[]), title('image labeled by cluster index');


    q
end


nres = medfilt2(res,3*[1 1]);
 figure(523453232)
    imshow(nres,[]), title('image labeled by cluster index');




% se = strel('disk',1);
% 
% resimg = imclose(pixel_labels,se);
% 
% imshow(resimg,[]), title('image labeled by cluster index');
% pause
% resimg = imclose(resimg,se);
% imshow(resimg,[]), title('image labeled by cluster index');
% 


return

fulldat(isGood(:)~=1,:) = NaN;

% 
figure(241431)
clf
plot(xx,circshift(cluster_center,5,2)')



[coeff score latent] = pca(fulldat,'algorithm','svd')


iT = fulldat*coeff;


for i=1:N_seg
    figure(1241)
    clf
    Ipc1 = reshape(iT(:,i),size(red_dat,1),size(red_dat,2));
    imshow(Ipc1,[],'InitialMagnification',50*N_block);
    
    figure(13413241)
    clf
    plot(xx,coeff(:,i))
    pause
end

Ipc1 = reshape(iT(:,1),size(red_dat,1),size(red_dat,2));
Ipc2 = reshape(iT(:,2),size(red_dat,1),size(red_dat,2));
% Ipc3 = reshape(iT(:,3),size(red_dat,1),size(red_dat,2));
Ipc = Ipc1+Ipc2;

Ipc(Ipc==0) = NaN;

figure(2412)
clf
imshow(Ipc,[],'InitialMagnification',50*N_block);




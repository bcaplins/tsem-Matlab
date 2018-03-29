im = imread('lacey-carbon-film.jpg');
im = mean(double(im(1:640,:,:))/255,3);
imshow(im)



im1 = 1-im(:,1:650);
im2 = 1-im(:,551:end);

idxs = find(im1<0.3);
im1(idxs) = rand(size(idxs))*0.1;
idxs = find(im2<0.3);
im2(idxs) = rand(size(idxs))*0.1;


im1 = im1+rand(size(im1))*.2;
im2 = im2+rand(size(im2))*.2;

figure(1)
clf
subplot(2,1,1)
imshow(im1)
subplot(2,1,2)
imshow(im2)

del = 10;
dis = (-100:del:100)+del/2;
djs = (400:del:600)+del/2;

[Dis Djs] = meshgrid(dis,djs);

errs = zeros(size(Dis));
tic
for idx=1:numel(errs)
    errs(idx) = imageError(im1,im2,[Dis(idx) Djs(idx)]);
end
toc

figure(321)
clf
% contourf(Dis,Djs,errs)
f = mesh(Dis,Djs,errs)
f.FaceColor = 'interp'

axis square

[serrs sidxs] = sort(errs(:),'descend');



[y i] = max(errs(:))

[Dis(i) Djs(i)]






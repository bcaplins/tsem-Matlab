function dat = loadImageStack(pre,N_dig,N_imgs,offset)
    if(nargin<4)
        offset = 0;
    end
    
    post = '.tif'

    format_str = ['%0.' num2str(N_dig) 'd'];
    
    fn = [pre sprintf(format_str,offset) post];
    im = double(imread(fn))/255;
    sz = size(im);
    
    dat = zeros(sz(1),sz(2),N_imgs);
    dat(:,:,1) = im;
    
    for i=2:N_imgs
        fn = [pre sprintf(format_str,i+offset-1) post];
        dat(:,:,i) = double(imread(fn))/255;
    end

end
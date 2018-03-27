function [se dfs] = loadRotDFStack(pre,N_dig,N_seg,roi_i,roi_j,df_scalefactor)

    if nargin<6
        df_scalefactor = 7;
    end

    post = '.tif'

    format_str = ['%0.' num2str(N_dig) 'd'];

    se = double(imread([pre sprintf(format_str,0) post]))/255;
    se = se(roi_i,roi_j); 

    dfs = zeros(length(roi_i),length(roi_j),N_seg);


    for i=1:N_seg
        fn = [pre sprintf(format_str,i) post];
        im = double(imread(fn))/255;
        dfs(roi_i,roi_j,i) = im(roi_i,roi_j)*df_scalefactor;
    end

end
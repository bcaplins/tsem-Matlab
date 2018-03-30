function red_dat = blockAverageData(dat,N_block)
    sz = size(dat);
    
    if (mod(sz(1),N_block) ~= 0) | (mod(sz(2),N_block) ~= 0)
        error('Cannot evenly divide input data')
    end
    
    
    if(numel(sz)==3)

        red_dat = zeros(sz(1)/N_block,sz(2)/N_block,sz(3));
        for i=1:sz(1)/N_block
            for j=1:sz(2)/N_block
                i_idxs = (i*N_block-N_block+1):(i*N_block);
                j_idxs = (j*N_block-N_block+1):(j*N_block);
                tmp = sum(sum(dat(i_idxs,j_idxs,:),2),1)/N_block/N_block;
                red_dat(i,j,:) = tmp(:);
            end
        end    

    elseif(numel(sz)==2)
        red_dat = zeros(sz(1)/N_block,sz(2)/N_block);
        for i=1:sz(1)/N_block
            for j=1:sz(2)/N_block
                i_idxs = (i*N_block-N_block+1):(i*N_block);
                j_idxs = (j*N_block-N_block+1):(j*N_block);
                red_dat(i,j) = sum(sum(dat(i_idxs,j_idxs,:),2),1)/N_block/N_block;
            end
        end  
    else
        error('WHHATT?')
    end
end
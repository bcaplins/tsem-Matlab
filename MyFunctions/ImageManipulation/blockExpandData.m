function exp_dat = blockExpandData(dat,N_block)
    curr_sz = size(dat);
           
    if(numel(curr_sz)==3)

        exp_dat = zeros(curr_sz(1)*N_block,curr_sz(2)*N_block,curr_sz(3));
        for i=1:curr_sz(1)
            for j=1:curr_sz(2)
                i_idxs = (i*N_block-N_block+1):(i*N_block);
                j_idxs = (j*N_block-N_block+1):(j*N_block);
                exp_dat(i_idxs,j_idxs,:) = repmat(dat(i,j,:),N_block,N_block,1);
            end
        end    

    elseif(numel(curr_sz)==2)
        
        exp_dat = zeros(curr_sz(1)*N_block,curr_sz(2)*N_block);
        for i=1:curr_sz(1)
            for j=1:curr_sz(2)
                i_idxs = (i*N_block-N_block+1):(i*N_block);
                j_idxs = (j*N_block-N_block+1):(j*N_block);
                exp_dat(i_idxs,j_idxs) = dat(i,j);
            end
        end    
    else
        error('WHHATT?')
    end
end
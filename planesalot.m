B = [1 0 0];

twinp = [-1 1 1];

twinp_n = twinp/norm(twinp);

3*(B-2*(dot(twinp_n,B)*twinp_n))
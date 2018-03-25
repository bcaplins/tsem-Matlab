function corrected_rate = correctPMTcountrate(obs_rate,pulse_pair_res_t)

    if(nargin<2)
        pulse_pair_res_t = 1/4e4;
    end

    corrected_rate = obs_rate/(1-obs_rate*pulse_pair_res_t);

end
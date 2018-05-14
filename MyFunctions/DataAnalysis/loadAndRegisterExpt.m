function [se2,dat] = loadAndRegisterExpt(ex)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

    % Load and register images

    if(~exist('reg_dat.mat','file'))

        [se2 dat] = regImages(ex);
        dat(isnan(dat)) = 0;
        se2(isnan(se2)) = 0;

        se2 = uint8(se2*255);
        dat = uint8(dat*255);

        save('reg_dat.mat','se2','dat')
    end

    S = load('reg_dat.mat');

    se2 = double(S.se2)/255;
    dat = double(S.dat)/255;


end


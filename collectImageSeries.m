fmat = [];
fvec = [];
gmat = [];
gvec = [];

doCalibrations

EHT = 30000; % Volts
SAMP_WD = 10.7; % mm
DET_WD = 25.53; % mm

% Example of bright field mask based on angle
% thetas = 0.00:0.01:0.150;

thetas = [0 3]./1000

% thetas = [0 2
%     4 6
%     7 9
%     10 15
%     15 20
%     20 30
%     30 40
%     40 50
%     50 60
%     60 70
%     70 80
%     80 100
%     100 125
%     125 150
%     150 200
%     200 250]./1000;

% Set up LEO
closeAllSerialConnections();
cp = openLeoConnection(getLeoComPort());

dmd = startDMDproc(getTemImageLoaderExe());

for i=1:length(thetas)
    theta_i = thetas(i,1);
    theta_o = thetas(i,2);
    pix_i_r = convertScatteringAngleToPixelRadius(theta_i,DET_WD,SAMP_WD)
    pix_o_r = convertScatteringAngleToPixelRadius(theta_o,DET_WD,SAMP_WD)
    mri = round(1000*theta_i);
    mro = round(1000*theta_o);
    fn = sprintf('C_mask_mrad_%0.4i_%0.4i.bmp',mri,mro)
    makeAnnularMask(fn,pix_i_r,pix_o_r,0,fmat,fvec,gmat,gvec)                
 
    writeToDMDproc(dmd,fn)
    fn
    
    return
    LeoWrite(cp,'RATE 9')
%     pause(1)
    LeoRead(cp)
    LeoRead(cp)
    
    LeoWrite(cp,'LINT 8')
%     pause(1)
    LeoRead(cp)
    LeoRead(cp)
    
        pause(1)
    isIntegrating = true;
    while isIntegrating
        LeoWrite(cp,'INT?')
        pause(1)
        LeoRead(cp)
        resp = LeoRead(cp)
        if(length(resp)~=2)
            error('NOOOOOO')
        else
            isIntegrating = (resp(2) == '0');
        end
    end
    
    LeoWrite(cp,'SREC')
%     pause(1)
    LeoRead(cp)
    LeoRead(cp)
    

end


closeAllSerialConnections();
endDMDproc(dmd)


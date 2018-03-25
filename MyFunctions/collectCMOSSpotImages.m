function fnames = collectCMOSSpotImages(calib_img_dir,cmos_args,X,semScanParams)

% cmos_args_struct should have gain, exposure_ms, and blacklevel fields
% X should be in SEM beam coords and be 2xN
% rot should be Nx1

sz = size(X);
if(sz(1) ~=2)
    error('Must be 2xN vector');
end

% The supplied directory must end with a slash
if(length(calib_img_dir)>0)
    if(calib_img_dir(end)~='\')
        calib_img_dir = [calib_img_dir '\'];
    end
end

% Beam coordinated to scan.. tehcnically 1024 and 768 are not valid...
% should be 1023 abd 767.. but no matter

% Start the DMD process and turn all mirrors towards camera
dmd = DMDController();
dmd.start();
dmd.writeUpMaskToDMD();

% Start the CMOS process and wait for initialization
cmos = CMOSController([],cmos_args,1);
cmos.start();

% Connect to LEO via serial
leo = RemCon32Microscope();
leo.openConnection();

% Set up LEO
leo.cmdNormalMode();
leo.cmdPixelAverage();
leo.cmdScanRotateToggle(1);
leo.cmdMag(semScanParams(1).mag);
leo.cmdWorkingDistance(semScanParams(1).wd);
leo.cmdBeamBlankToggle(0);


% TODO read pixel size and write to calibration directory
resp = leo.queryPixelSize();
um_per_pix = resp/1000

fnames = cell(length(X),1);

% Loop through all beam positions
for i=1:length(X)
	if(numel(semScanParams) == 1)
        semParam = semScanParams;
    else
        semParam = semScanParams(i)
    end
    
    % Set up LEO 
    leo.cmdNormalMode();
    if(semParam.scanrotenable)
        leo.cmdScanRotate(semParam.scanrot);
    else
        leo.cmdScanRotate(0);
    end
    leo.cmdSpotMode(X(1,i),X(2,i));    
        
    fname = sprintf('SPOT_calib_%.4d_%.4d_%.4d_capture.png',X(1,i),X(2,i),semParam.scanrot*10);
    fnames{i} = fname;
    
    fullpath = [calib_img_dir fname];
    
    cmos.saveCmosImage(fullpath);

end

% Reture LEO to normal operation
leo.cmdNormalMode();
leo.cmdBeamBlankToggle(1);
leo.cmdScanRotateToggle(0);

% Close the com port
leo.closeAllSerialConnections();

% End CMOS process
cmos.stop();

% End DMD process
dmd.stop();

function fnames = collectDMDSpotImages(calib_img_dir,cmos_args,X)

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

% DMD coordinated to scan.. 1024x768

% Start the DMD process
dmd = DMDController();
dmd.start();
% dmd.writeDownMaskToDMD();

% Start the CMOS process and wait for initialization
cmos = CMOSController([],cmos_args,1);
cmos.start();

% % Save bg image
% bgfname = sprintf('MASK_bg_capture.png');
% fullpath = [calib_img_dir bgfname];
% cmos.saveCmosImage(fullpath);


fnames = cell(length(X),1);

mask = MaskImage();
mask.initializeMask(ImageTypes.DMD);

PIX_RAD = 3;

% Loop through all beam positions
for i=1:length(X)
    
    mask.makeSpotsMask(X(:,i),PIX_RAD,0);
    maskfn = mask.saveImageAsBMP([calib_img_dir 'currentMask']);
    dmd.writeFileToDMD(maskfn);
       
    fname = sprintf('MASK_calib_%.4d_%.4d_capture.png',X(1,i),X(2,i));
    fnames{i} = fname;
    
    fullpath = [calib_img_dir fname];
    
    cmos.saveCmosImage(fullpath);

end

% End CMOS process
cmos.stop();

% End DMD process
dmd.stop();

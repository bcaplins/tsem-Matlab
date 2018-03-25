% This should be run from the image data directory


%% Run DMD calibration
% Easiest is to put a piece of paper on top of YAG and shine light on it
% Should only need to be redone when camera or dmd are moved\
% 
% cmos_args = CMOSArgs(300, 100, 255);% [esposure gain blacklevel]
% dmd_calib_img_dir = 'Z:\20171127\cal\';
x = 300:64:620;
y = 250:64:570;
[X Y] = meshgrid(x,y);
X_dmd = ImageMapping.meshGridToRowVec(X,Y);
% fnames = collectDMDSpotImages(dmd_calib_img_dir,cmos_args,X_dmd)
% 
% PIX_THRESH = 0.15;
% [gmat, gvec] = calculateDMDcalib(dmd_calib_img_dir,fnames,X_dmd,PIX_THRESH)

 
gmat =[    0.6905    0.0245
    0.0357    0.6931]


gvec =[ -214.7958
   13.0063]



%% Run CMOS calibration
% 10 um aperture is fine
% Will be sensitive to the exact position of the detector, so will probably
% % changed with every insertion
% % Must have reasonable WD or mag will not set

% cmos_args = CMOSArgs(13, 0, 190);% [esposure gain blacklevel]
% cmos_calib_img_dir = 'Z:\20171127\cal\';
x = round(linspace(0,1023,8));
y = round(linspace(0,767,6));
[X Y] = meshgrid(x,y);
X_beam = ImageMapping.meshGridToRowVec(X,Y);
semScanParam = BasicSEMScanParameters(22.7,70,0,0);
% fnames = collectCMOSSpotImages(cmos_calib_img_dir,cmos_args,X_beam,semScanParam)
% 
% PIX_THRESH = 0.5;
% [fmat, fvec] = calculateCMOScalib(cmos_calib_img_dir,fnames,X_beam,semScanParam,PIX_THRESH)

fmat =[   -1.1994    9.2593
    9.3862    2.1312]


fvec =   1.0e+04 *[   -0.3353
   -1.1013]




img_mapping = ImageMapping(fmat,fvec,gmat,gvec,0);

cmos_grid_img = MonochromeImage('cal\MAX_CMOS_STACK.png');
yag_grid_img = img_mapping.doMapping(cmos_grid_img,ImageMapping.CMOS_IMAGE,ImageMapping.YAG_IMAGE);
figure(123),clf

Xbeam = ImageMapping.mapFromNonrotatedSpatialCoordsToRotatedBeamCoords(...
    ImageMapping.meshGridToRowVec(yag_grid_img.X,yag_grid_img.Y),...
    semScanParam);
[yag_grid_img.X yag_grid_img.Y] = ImageMapping.rowVecToMeshGrid(Xbeam,size(yag_grid_img.X));

plot(yag_grid_img)
hold on
plot(X_beam(1,:),X_beam(2,:),'ro')


cmos_grid_img = MonochromeImage('cal\MAX_DMD_STACK.png');
dmd_grid_img = img_mapping.doMapping(cmos_grid_img,ImageMapping.CMOS_IMAGE,ImageMapping.DMD_IMAGE);
figure(124),clf
plot(dmd_grid_img)
hold on
plot(X_dmd(1,:),X_dmd(2,:),'ro')




% Save into the current data directory
% save('CALIB','fmat','fvec','gmat','gvec');



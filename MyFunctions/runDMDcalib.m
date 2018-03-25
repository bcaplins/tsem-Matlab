function runDMDcalib(calib_img_dir,CMOS_PROGRAM_ARGS)

% The supplied directory must end with a slash
SAVED_IMAGE_DIR = calib_img_dir;

if(nargin<2)
    CMOS_PROGRAM_ARGS = ' --gain 50 --exposure 1000 --blacklvl 180 --filename "';
end

CMOS_IMAGE_COLLECT_PROG = getTemImageAcquisitionExe();
DMD_MASK_PROG = getTemImageLoaderExe();

DMD_MASK_PATH = 'C:\Users\1TEM\Documents\MATLAB\MASKS\';

% Get the filesnames for the dmd masks
dmd_files = cellstr(ls([DMD_MASK_PATH '*calib*']));

% Start up the DMD program
dmd_proc = startDMDproc(DMD_MASK_PROG);

% Loop through all mirror picture file
for index = 1:length(dmd_files)
  
    % display file name in command window
    disp([dmd_files{index}]);

    % send file name to mirror controlling program (followed by newline)
    writeToDMDproc(dmd_proc,[DMD_MASK_PATH dmd_files{index}]);
    
    % pause X seconds to allow mirror to settle (probably not necessary)
    pause(1);

    % Take a picture and save to file name based on dmd_file name
    % Gain can be set by adding option --gain <num> where <num> ranges from 0 to 100
    % The --quiet option silences all output except for error messages
    system([CMOS_IMAGE_COLLECT_PROG CMOS_PROGRAM_ARGS SAVED_IMAGE_DIR dmd_files{index}(1:end-4) '_capture.png"']);
  
end

% Close the mirror program and allow it to clean up resources
endDMDproc(dmd_proc);
clear dmd_proc;
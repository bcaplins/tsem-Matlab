classdef DMDController < handle & DotNetSuperProcess
    
    properties (Constant)
        UP_MASK_PATH = 'C:\Users\1TEM\Documents\MATLAB\tsem-Matlab\MASKS\UP.bmp';
        DOWN_MASK_PATH = 'C:\Users\1TEM\Documents\MATLAB\tsem-Matlab\MASKS\DOWN.bmp';
    end
    
    methods
        function obj = DMDController(path)
            if (nargin<1)
                path = 'C:\Users\1TEM\Documents\1TEM_control\tem_image_loader\bin\Release\tem_image_loader.exe';
            end
            obj@DotNetSuperProcess(path);
        end
        
        function start(obj)
            [status, result] = system('taskkill /F /IM tem_image_loader.exe /T');
            if(status==0)
                disp('Killed old DMD process')
                disp(result);
            end
            obj.startProcess();
            obj.writeUpMaskToDMD();
            pause(1);
        end
        
        function stop(obj)
            obj.endProcess();
        end
        
        function writeFileToDMD(obj,mask_path)
            obj.writeToProcess(mask_path);
            pause(0.25);
        end
        
        function writeUpMaskToDMD(obj)
            obj.writeFileToDMD(obj.UP_MASK_PATH);
        end
        function writeDownMaskToDMD(obj)
            obj.writeFileToDMD(obj.DOWN_MASK_PATH);
        end
    end
end


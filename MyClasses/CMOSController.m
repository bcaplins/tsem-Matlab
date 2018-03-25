classdef CMOSController < handle & DotNetSuperProcess
    
    properties 
        cmos_args CMOSArgs;
    end
    
    properties (Constant)
        TIMEOUT = 15;
    end
    
    methods
        function obj = CMOSController(path,cmos_args,useInteractive)
            if nargin~=3
                error('Supply All Constructor Arguments')
            end
            
            if isempty(path)               
                if(useInteractive)
                    path = 'C:\Users\1TEM\Documents\1TEM_control\tem_image_acquisition_softwaretriggered\bin\Release\tem_image_acquisition.exe'; 
                else
                    path = 'C:\Users\1TEM\Documents\1TEM_control\tem_image_acquisition\bin\Release\tem_image_acquisition.exe';
                end
            end
            
            obj@DotNetSuperProcess(path,cmos_args.toString());
            obj.cmos_args = cmos_args;
        end        
        
        function start(obj)
            [status, result] = system('taskkill /F /IM tem_image_acquisition.exe /T');
            if(status==0)
                disp('Killed old CMOS process')
                disp(result)
            end
            obj.startProcess()
            pause(obj.cmos_args.exposure_ms/1000+2);
        end
        
        function stop(obj)
            obj.endProcess();
        end
        
        function saveCmosImage(obj,img_fullpath)     
            tic;
            if(exist(img_fullpath)==2)
                error('FILES ALREADY EXIST!')
            end
            
            obj.writeToProcess(img_fullpath);
            total_wait = 0;
            while(exist(img_fullpath)~=2)
               sec = obj.cmos_args.exposure_ms/1000;
               sleepy = max(sec/10,0.1);
               pause(sleepy);       
               total_wait = total_wait+sleepy;
               if(total_wait > obj.TIMEOUT)
                   error('Timeout on waiting for image to save')
               end
            end
            pause(0.05)
            total_wait = toc;
            fprintf('%d ms spent collecting a %d ms image\n',round(total_wait*1000),obj.cmos_args.exposure_ms);
        end
    end
end
classdef BasicSEMScanParameters
    
    properties
        wd;
        scanrotenable;
        scanrot;
        mag;
    end
    
    methods
        function obj = BasicSEMScanParameters(wd,mag,scanrotenable,scanrot)
            obj.wd = wd;
            obj.mag = mag;
            if(nargin<=2)
                obj.scanrot = 0;
                obj.scanrotenable = 0;
            else
                if(scanrotenable)
                    obj.scanrot = scanrot;
                    obj.scanrotenable = scanrotenable;
                else
                    obj.scanrot = 0;
                    obj.scanrotenable = 0;
                end
                
            end
        end
    end
    
    methods (Static)
        function yag_pixel_size_meters = convertMagToPixelSize(mag)
            % Assumes output device mag setting in SmartSEM
            mref = 100;
            pixref = 1e-6*2894.7/1024;
            yag_pixel_size_meters = (mref/mag)*pixref;
        end
    end
    
end


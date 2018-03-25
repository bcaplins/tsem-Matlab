classdef CMOSArgs
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        exposure_ms;
        gain;
        blacklevel;
    end
    
    methods
        
        function obj = CMOSArgs(exposure_ms, gain, blacklevel)
            obj.exposure_ms = exposure_ms;
            obj.gain = gain;
            obj.blacklevel = blacklevel;
        end
        
        function str = toString(obj)
            str = sprintf(' --gain %d --exposure %d --blacklvl %d ',...
                obj.gain,...
                obj.exposure_ms,...
                obj.blacklevel);
        end
    end
    
end


classdef MonochromeImage < BasicImage
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties        
    end
    
    methods
        
        function hand = plot(obj,contrast,brightness)
            if(nargin<2)
                contrast = 1;
                brightness = 0;
            end
            [xs ys] = obj.getCorners();
            hand = image(xs,ys,contrast*obj.getPlotFriendlyData()+brightness);
%             axis square
%             axis equal
                axis image
        end
        
        function obj = MonochromeImage(arg1)
            if(nargin<1)
                arg1 = [];
            end
            obj@BasicImage(arg1);
            if(~isempty(obj.img))
                obj.img = MonochromeImage.convertDataToMonochrome(obj.img);
            end
        end
        
                
                
        function fn = saveImageAsBMP(obj,fn)
            bmpdat = uint8(255*repmat(obj.img,[1 1 3]));
            if(~strcmpi(fn(end-3:end),'.bmp'))
                fn = [fn '.bmp'];
            end
            
            imwrite(bmpdat,fn,'bmp');
        end
        
        function fn = saveImageAsPNG(obj,fn)
            bmpdat = uint8(255*repmat(obj.img,[1 1 3]));
            if(~strcmpi(fn(end-3:end),'.png'))
                fn = [fn '.png'];
            end
            
            imwrite(bmpdat,fn,'png');
        end
        
        function dat = getPlotFriendlyData(obj)
            dat = double(repmat(obj.img,[1 1 3]));
        end

    end

    methods (Static)
        function mono_dat = convertDataToMonochrome(dat)
            
                cls = class(dat(1));
                
                if(strcmp(cls,'uint8'))
                    mono_dat = double(dat)./(2^8-1);
                elseif(strcmp(cls,'uint16'))
                    mono_dat = double(dat)./(2^16-1);
                elseif(strcmp(cls,'logical'))
                    mono_dat = double(dat);
                elseif(strcmp(cls,'double'))
                    mono_dat = dat;
                else
                   error('Not Supported') 
                end
                
                mono_dat = mono_dat(:,:,1);
                                
        end
    end
end


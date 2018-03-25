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
        
        function dat = getPlotFriendlyData(obj,rgb)
            if(nargin<2)
                dat = MonochromeImage.getPlotFriendlyDataStatic(obj.img);
            else
                dat = MonochromeImage.getPlotFriendlyDataStatic(obj.img,rgb);
            end
        end
    
        function equalizeIntHistogram(obj,low_percent,high_percent)
            obj.img = MonochromeImage.equalizeIntHistogramStatic(obj.img,low_percent,high_percent);
        end
        
        function removeOutOfBoundsData(obj)
            obj.img = MonochromeImage.removeOutOfBoundsDataStatic(obj.img);
        end
    end

    methods (Static)
        
        function rgb_dat = getPlotFriendlyDataStatic(mono_dat,rgb)
            if(nargin>1)
                rgb_dat = zeros([size(mono_dat) 3]);
                rgb_dat(:,:,1) = mono_dat*rgb(1);
                rgb_dat(:,:,2) = mono_dat*rgb(2);
                rgb_dat(:,:,3) = mono_dat*rgb(3);
            else
                rgb_dat = double(repmat(mono_dat,[1 1 3]));
            end
        end
        
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
        
        function sc_dat = equalizeIntHistogramStatic(dat,low_percent,high_percent)
            edges = linspace(0,1.00,10001);
            edges(1) = -Inf;
            edges(end) = Inf;
            N = histcounts(dat(:),edges,'Normalization','cdf');
           [dummy, min_idx] = min(abs(N-low_percent));
           [dummy, max_idx] = min(abs(N-high_percent));
           
           min_val = edges(min_idx);
           if(isinf(min_val))
               min_val = 0;
           end
           
           max_val = edges(max_idx+1);
           if(isinf(max_val))
               max_val = 1;
           end
                      
           sc_dat = (1-0)*(dat-min_val)/(max_val-min_val);
            
%             if(sum((sc_dat(:)>1)))
%                 min_val
%                 max_val
%                 min(dat(:))
%                 max(dat(:))
%                 max(sc_dat(:))
%                 error('WTF')
%             end

        end
        
        function dat = removeOutOfBoundsDataStatic(dat)
            dat(dat(:)>=1) = 0.999;
            dat(dat(:)<=0) = 0.001;
        end
        
    end
end


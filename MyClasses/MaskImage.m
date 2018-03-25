classdef MaskImage < MonochromeImage
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = MaskImage(arg1)
            if (nargin<1)
                arg1 = [];
            end
            obj@MonochromeImage(arg1);
            if(~isempty(obj.img))
                obj.img = MaskImage.convertDataToMask(obj.img);
            end
        end
        
        function hand = plot(obj,col,alpha)
            dat = zeros([size(obj.img) 3]);
            dat(:,:,1) = col(1)*obj.img;
            dat(:,:,2) = col(2)*obj.img;
            dat(:,:,3) = col(3)*obj.img;
            
            
            [xs ys] = obj.getCorners();
            hand = image(xs,ys,dat);
            hand.AlphaData = alpha*obj.img;
%             axis square
%             axis equal
                axis image
        end
        
        function initializeMask(obj,imageType,doInvert)
            if(nargin<3)
                doInvert = logical(0);
            end
            
            [X Y] = ImageMapping.getDestGrid(imageType);
            obj.imgType = imageType;
            obj.X = X;
            obj.Y = Y;
                                
            obj.img = logical(doInvert+zeros(size(X)));
        end
        function invertMask(obj)
            obj.img = ~obj.img;
        end
        
        function makeAnnularMask(obj,center_pix,rad_inner_pix,rad_outer_pix,doInvert)
            obj.img(:) = logical(doInvert);
            dX =  obj.X-center_pix(1);
            dY =  obj.Y-center_pix(2);
            d = sqrt(dX.^2+dY.^2);
            
            obj.img(d>rad_inner_pix & d<=rad_outer_pix) = ~logical(doInvert);
        end
        
        function makeWedgeMask(obj,center_pix,theta_rad_a,theta_rad_b,doInvert)
            
            if(theta_rad_a>2*pi)
                theta_rad_a = theta_rad_a-2*pi;
            end
            if(theta_rad_b>2*pi)
                theta_rad_b = theta_rad_b-2*pi;
            end
            [theta_rad_a theta_rad_b]
            
            obj.img(:) = logical(doInvert);
            dX =  obj.X-center_pix(1);
            dY =  obj.Y-center_pix(2);
            ang_rad = atan2(dY,dX);
            idxs = find(ang_rad<0);
            ang_rad(idxs) = ang_rad(idxs)+2*pi;
            if(theta_rad_b<theta_rad_a)
                obj.img(ang_rad>=theta_rad_a | ang_rad<=theta_rad_b) = ~logical(doInvert);
            else
                obj.img(ang_rad>=theta_rad_a & ang_rad<=theta_rad_b) = ~logical(doInvert);
            end
        end
        
        function makeSpotsMask(obj,spots_pix,spot_rad_pix,doInvert)
            obj.img(:) = logical(doInvert);
            sz = size(spots_pix);
            if(sz(1) ~= 2)
                error('Req 2xN')
            end
            for i=1:sz(2)
                dX =  obj.X-spots_pix(1,i);
                dY =  obj.Y-spots_pix(2,i);
                d = sqrt(dX.^2+dY.^2);
                obj.img(d<=spot_rad_pix) = ~logical(doInvert);
            end
        end
        
    end
    
    methods (Static)
        function mask_data = convertDataToMask(dat)
            mask_data = logical(round(MonochromeImage.convertDataToMonochrome(dat)));
        end
        
        function mask = combineMasks(basemask,varargin)
            
            mask = MaskImage();
            mask.X = basemask.X;
            mask.Y = basemask.Y;
            mask.img = basemask.img;
            
            for i=1:length(varargin)
                mask.img = mask.img.*varargin{i}.img;
            end

        end
        
    end
    
end


classdef BasicImage < handle
    
    properties
        img;
        imgType;
        X;
        Y;
    end
    
    methods 
        function obj = BasicImage(arg1)
            if(isempty(arg1) || nargin<1)
                
            elseif(isa(arg1,'ImageTypes'))
                obj.imgType = arg1;
                [obj.X, obj.Y] = ImageMapping.getDestGrid(arg1);
                obj.img = zeros([size(obj.X) 3]);
            elseif(isa(arg1,'BasicImage'))
                obj.img = arg1.img;
                obj.imgType = arg1.imgType;
                obj.X = arg1.X;
                obj.Y = arg1.Y;
            elseif(isa(arg1,'char'))
                obj.img = imread(arg1);
                sz = size(obj.img);
                [obj.X, obj.Y] = meshgrid(1:sz(2),1:sz(1));
                obj.imgType = ImageTypes.UNSPECIFIED;
            else
                error('AHHH')
            end
                
        
        end        
        
        function nd = numImageChannels(obj)
            nd = size(obj.img,3);
        end
        
        function [xs ys] = getCorners(obj)
            xs = [obj.X(1,1) obj.X(end,end)];
            ys = [obj.Y(1,1) obj.Y(end,end)];
        end
        
        function set.imgType(obj,imgType)
            % At some point I should add errror checking here
            obj.imgType = imgType;
        end
       
    end
    
    
        
        
end
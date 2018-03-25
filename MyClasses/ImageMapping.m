classdef ImageMapping
    %IMGTRAN Summary of this class goes here
    %   Detailed explanation goes here

    properties 
        extrap_val;
    end
    
    properties (Access = private)
        fmat;
        fvec;
        gmat;
        gvec;
        um_per_pix;
    end
    
    
    methods
        function obj = ImageMapping(fmat,fvec,gmat,gvec,extrap_val)
            obj.fmat = fmat;
            obj.fvec = fvec;
            obj.gmat = gmat;
            obj.gvec = gvec;
            if(nargin==4)
                obj.extrap_val = 0;
            else
                obj.extrap_val = extrap_val;
            end
        end
        function str = fToString(obj)
            str = sprintf('f=[%s,%s\n%s,%s]\n',num2str(obj.fmat(1,:)),num2str(obj.fvec(1)),...
                num2str(obj.fmat(2,:)),num2str(obj.fvec(2)));
        end
        
        function str = gToString(obj)
            str = sprintf('g=[%s,%s\n%s,%s]\n',num2str(obj.gmat(1,:)),num2str(obj.gvec(1)),...
                num2str(obj.gmat(2,:)),num2str(obj.gvec(2)));
        end
        
        function fun = getMappingFunction(obj,fromType,toType)
            fun = ImageMapping.getMappingFunctionStatic(...
                obj.fmat,obj.fvec,obj.gmat,obj.gvec,fromType,toType);
        end
        
        function destImg = doMapping(obj,origImg,destType)
            origType = origImg.imgType;
            if(origType == ImageTypes.UNSPECIFIED)
                error('Cannot map unspecified iamge type')
            end
            
            revTrans = obj.getMappingFunction(destType,origType);
            
            % Determine destination grid
            [Xdest Ydest] = ImageMapping.getDestGrid(destType);
            sz = size(Xdest);
            
            XdestRow = ImageMapping.meshGridToRowVec(Xdest,Ydest);
            
            XqRow = revTrans(XdestRow);
            
            [Xq Yq] = ImageMapping.rowVecToMeshGrid(XqRow,sz);
            
            
            imgcls = class(origImg);
            if(strcmp(imgcls,'BasicImage'))
                destImg = BasicImage();
            elseif(strcmp(imgcls,'MonochromeImage'))
                destImg = MonochromeImage();
            elseif(strcmp(imgcls,'MaskImage'))
                destImg = MaskImage();
            else
                error('Not Supported')
            end            
            
            destImg.X = Xdest;
            destImg.Y = Ydest;
            nChan = origImg.numImageChannels();
            
            tmpDoubles = zeros([sz nChan]);
%             
%             MAP_TYPE = 'linear';
            MAP_TYPE = 'nearest';
            
            cls = class(origImg.img(1));
            if(~strcmp(cls,'double'))
                tmpDoubles(:,:,1) = interp2(origImg.X,origImg.Y,double(origImg.img(:,:,1)),...
                    Xq,Yq,...
                    MAP_TYPE,obj.extrap_val);
            else
                tmpDoubles(:,:,1) = interp2(origImg.X,origImg.Y,origImg.img(:,:,1),...
                    Xq,Yq,...
                    MAP_TYPE,obj.extrap_val);
            end
            for i=2:nChan
                tmpDoubles(:,:,i) = tmpDoubles(:,:,1);
            end
            
            destImg.img = cast(tmpDoubles,cls);
           
            
                        
        end
        
            
    end
    
    methods (Static)
              
        function Xout = mapFromNonrotatedSpatialCoordsToRotatedBeamCoords(Xin,semScanParams)
            sz = size(Xin);
            if(sz(1) ~= 2)
                error('Must use 2xN matrix')
            end
            
            if(semScanParams.scanrotenable)
                rot = semScanParams.scanrot;
            else
                rot = 0;
            end
            
            Xout = Xin./(1e6*BasicSEMScanParameters.convertMagToPixelSize(semScanParams.mag));
            
            rotfun = ImageMapping.clockwiseRotationMatrixFunction();
            Xout = rotfun(rot*pi/180)*Xout;
            
            C = [1023/2 767/2]';
            Xout = Xout+C;            
        end
        
        function Xout = mapFromRotatedBeamCoordsToNonrotatedSpatialCoords(Xin,semScanParams)
            sz = size(Xin);
            if(sz(1) ~= 2)
                error('Must use 2xN matrix')
            end
            
            if(semScanParams.scanrotenable)
                rot = -semScanParams.scanrot;
            else
                rot = 0;
            end
            % Unrotate
            C = [1023/2 767/2]';
            rotfun = ImageMapping.clockwiseRotationMatrixFunction();
            Xout = Xin-C;
            Xout = rotfun(rot*pi/180)*Xout;
            
            % Convert to real space in microns in optic axis centered
            % coords
            Xout = 1e6*BasicSEMScanParameters.convertMagToPixelSize(semScanParams.mag)*Xout;            
        end
		
        function fun = getMappingFunctionStatic(fmat,fvec,gmat,gvec,fromType,toType)
              % Create basic mapping functions
            f = @(X) fmat*X+fvec;
            g = @(X) gmat*X+gvec;
            ginv = @(X) inv(gmat)*(X-gvec);
            finv = @(X) inv(fmat)*(X-fvec);
            
            % Create composite (inverse) mapping functions
            % Recall it is better to do an inverse transform of the
            % destination and interpolate in the original image than to do
            % the forward transform
            if(fromType == ImageTypes.DMD)
                if(toType == ImageTypes.YAG)
                    fun = @(X) f(ginv(X));
                elseif(toType == ImageTypes.CMOS)
                    fun = @(X) ginv(X);
                else
                   error('Unsupported') 
                end 
            elseif(fromType == ImageTypes.YAG)
                if(toType == ImageTypes.DMD)
                    fun = @(X) g(finv(X));
                elseif(toType == ImageTypes.CMOS)
                    fun = @(X) finv(X);
                else
                   error('Unsupported') 
                end 
            elseif(fromType == ImageTypes.CMOS)
                if(toType == ImageTypes.DMD)
                    fun = @(X) g(X);
                elseif(toType == ImageTypes.YAG)
                    fun = @(X) f(X);
                else
                   error('Unsupported') 
                end 
            else
                error('Not Supported'); 
            end
            
        end
        
        
        
        function [X Y] = getDestGrid(imgType)
            if(imgType == ImageTypes.DMD)
                [X Y] = meshgrid(1:1024,1:768);
            elseif(imgType == ImageTypes.CMOS)
                [X Y] = meshgrid(1:1600,1:1200);
            elseif(imgType == ImageTypes.YAG)
                N = 2*1024;
                wid = 10000; % microns
                x = linspace(-wid/2,wid/2,N);
                y = linspace(-wid/2,wid/2,N);
                
                [X Y] = meshgrid(x,y);
            elseif(imgType == ImageTypes.UNSPECIFIED)
                X = [];
                Y = [];
            else
                error('Not Supported'); 
            end
        end
        
        function Xrow = meshGridToRowVec(X,Y)
                Xrow = [X(:)'
                        Y(:)'];
        end
        
        function [X Y] = rowVecToMeshGrid(row,sz)
            X = reshape(row(1,:),sz);
            Y = reshape(row(2,:),sz);
        end
        
        function rotfun = clockwiseRotationMatrixFunction()
            rotfun = @(theta_rad) [cos(theta_rad) -sin(theta_rad);
                                sin(theta_rad) cos(theta_rad)];
        end
        
        
    end
    
    
end


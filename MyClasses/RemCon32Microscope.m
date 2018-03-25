classdef RemCon32Microscope < handle
    
    properties
        com_port;
        serial_obj;
    end
    
    
    methods (Access = private)
         function resp = cmdSetStagePosition(obj,xyz_mm,TR_deg)
            obj.cmdToggleSpecimenCurrentMonitor(0);
            if(xyz_mm(1)<0 || xyz_mm(1)>100 ...
                    || xyz_mm(2)<0 || xyz_mm(2)>100 ...
                    || xyz_mm(3)<0 || xyz_mm(3)>30 ...
                    || TR_deg(1)<0 || TR_deg(1)>90 ...
                    || TR_deg(2)<0 || TR_deg(2)>360)
                error('Move outside of even remotely reasonable bounds')
            end
            
            disp('STAGE MOVE CMD... GODSPEED.')
            disp(sprintf('C95 %.6d %.6d %.6d %.6d %.6d 0',xyz_mm(1),xyz_mm(2),xyz_mm(3),TR_deg(1),TR_deg(2)))
            obj.writeCommand(sprintf('C95 %.6d %.6d %.6d %.6d %.6d 0',xyz_mm(1),xyz_mm(2),xyz_mm(3),TR_deg(1),TR_deg(2)));
            resp = obj.checkResponse(obj.readResponse());
        end
    end
    
    methods
        
        function obj = RemCon32Microscope(cp)
            if (nargin<1)
                obj.com_port = 'COM4';
            else
                obj.com_port = cp;
            end
        end
        
        function out = writeCommand(obj,str)
            fprintf(obj.serial_obj,str);
            out = str;
        end
        
        function out = readResponse(obj)
            pause(0.1)
            out{1} = strtrim(fscanf(obj.serial_obj));
            out{2} = strtrim(fscanf(obj.serial_obj));
        end
        
        function openConnection(obj)
            
            obj.closeAllSerialConnections();
            
            obj.serial_obj = serial(obj.com_port);

            % set up parameters as indicated in LEO remote users guide
            set(obj.serial_obj,'Terminator','CR');
            set(obj.serial_obj,'BaudRate',9600);
            set(obj.serial_obj,'DataBits',8);
            set(obj.serial_obj,'Parity','none');
            set(obj.serial_obj,'FlowControl','none');
            set(obj.serial_obj,'StopBits',1);
            set(obj.serial_obj,'Timeout',1);

            fopen(obj.serial_obj);
            obj.cmdNull();
             
            
        end
        
        
        function resp = cmdNull(obj)
            obj.writeCommand('');
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdNormalMode(obj)
            obj.writeCommand('NORM');
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdPixelAverage(obj)
            obj.writeCommand('PXNR');
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdBeamBlankToggle(obj,bool)
            obj.writeCommand(sprintf('BBLK %d',logical(bool)));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdMag(obj,val)
            obj.writeCommand(sprintf('MAG %d',round(val)));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdScanRotateToggle(obj,bool)
            obj.writeCommand(sprintf('SRON %d',logical(bool)));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdSpotMode(obj,x,y)
            xround = round(x);
            yround = round(y);
            
            obj.writeCommand(sprintf('SPOT %.4d %.4d',xround,yround));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdBeamPosition(obj,x,y)
            obj.writeCommand(sprintf('BEAM %.6f %.6f',x,y));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdGunAlign(obj,x,y)
            obj.writeCommand(sprintf('GALN %.3f %.3f',x,y));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdApertureAlign(obj,x,y)
            obj.writeCommand(sprintf('GALN %.3f %.3f',x,y));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdScanRotate(obj,val)
            if(val<0)
                val = val+360;
            end
            if(val>360)
                val = val-360;
            end
            obj.writeCommand(sprintf('SRO %.6f',val));
            resp = obj.checkResponse(obj.readResponse());
        end
       
        function resp = cmdScanRate(obj,val)
            obj.writeCommand(sprintf('RATE %d',round(val)));
            resp = obj.checkResponse(obj.readResponse());
        end
       
        function resp = cmdFreezeToggle(obj)
            obj.writeCommand('FREZ');
            resp = obj.checkResponse(obj.readResponse());
        end
       
        function resp = cmdWorkingDistance(obj,val)
            obj.writeCommand(sprintf('FOCS %.6f',val));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdFrameIntegrate(obj,val)
            obj.writeCommand(sprintf('FINT %d',round(val)));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdLineIntegrate(obj,val)
            obj.writeCommand(sprintf('LINT %d',round(val)));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdRecordImage(obj)
            phnum = obj.queryPhotoNumber();
            
            obj.writeCommand('FREC');
            obj.checkResponse(obj.readResponse());
            resp = phnum;
        end
        
        function resp = cmdDetector(obj,str)
            obj.writeCommand(sprintf('DET %s',str));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdCenterBeamShift(obj)
            obj.writeCommand('CTRB');
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdSetBeamShift(obj,x_um,y_um)
            nrm = norm([x_um y_um]);
            if(nrm>15)
                disp('Beam shift can only go to 15 um from center. Rescaling accordingly!')
                x_um = 15*x_um/nrm
                y_um = 15*y_um/nrm
            end
            
            nrm = norm([x_um y_um]);
            
            calib_factor_x = 1.0267;
            calib_factor_y = 1.0164;
            
            x_norm = x_um/15/calib_factor_x;
            y_norm = y_um/15/calib_factor_y;
                       
            obj.writeCommand(sprintf('BEAM %.6d %.6d',x_norm,y_norm));
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = cmdToggleSpecimenCurrentMonitor(obj,val)
            obj.writeCommand(sprintf('SCM %d',logical(val)));
            resp = obj.checkResponse(obj.readResponse());
        end
        
       
        
        function resp = cmdSetStagePositionSafeish(obj,xyz_mm,TR_deg)
            
            
            xyz_ref = [58.75 8 0];
            TR_ref = [47.8 169];
            
            [xyz_curr, TR_curr, isMoving] = obj.queryStagePosition();
            
            if(isMoving)
                error('Stage currently moving');
            end
            
            % Req stage move to be 'close' to current position and a
            % reference position... close is poorly defined...
            
            % Ensure all inputs are the same orientation!
            del_ref = norm(xyz_mm(:)-xyz_ref(:));
            del_curr = norm(xyz_mm(:)-xyz_curr(:));
            
            if(del_ref>3 || del_curr>1)
                error('Moving too far in cartesian coordinates')
            end
            
            del_ref = abs(TR_deg(1)-TR_ref(1));
            del_curr = abs(TR_deg(1)-TR_curr(1));
            
            if(del_ref>2 || del_curr>1)
                error('Moving too far in the tilt coordinate')
            end
               
            del_ref = abs(TR_deg(2)-TR_ref(2));
            del_curr = abs(TR_deg(2)-TR_curr(2));
            
            if(del_ref>15 || del_curr>6)
                error('Moving too far in the rotate coordinate')
            end
                
            resp = obj.cmdSetStagePosition(xyz_mm,TR_deg);
            
        end
        
        
        
        
        
        
        function [xyz_mm, TR_deg, isMoving] = queryStagePosition(obj)
            % return X Y Z T R M STATUS
            pause(2);
            obj.writeCommand('C95?');
            resp = obj.checkResponse(obj.readResponse());
            tmp = sscanf(resp, '%f %f %f %f %f %f %f');
            xyz_mm = tmp(1:3);
            TR_deg = tmp(4:5);
            isMoving = (round(tmp(6))~=0);
        end
        
        function resp = queryIntegrationStatus(obj)
            pause(2);
            obj.writeCommand('INT?');
            resp = obj.checkResponse(obj.readResponse());
            resp = str2num(resp);
        end
        
        function resp = queryPixelSize(obj)
            obj.writeCommand('PIX?');
            resp = obj.checkResponse(obj.readResponse());
            resp = str2num(resp);
        end
        
        function resp = queryWorkingDistance(obj)
            obj.writeCommand('FOC?');
            resp = obj.checkResponse(obj.readResponse());
            resp = str2num(resp);
        end
        
        function resp = queryVersion(obj)
            obj.writeCommand('VER?');
            resp = obj.checkResponse(obj.readResponse());
        end
        
        function resp = queryPhotoNumber(obj)
            obj.writeCommand('PHN?');
            resp = obj.checkResponse(obj.readResponse())
            resp = str2num(resp);
        end
        
    end
    
    
    methods (Static)
        function closeAllSerialConnections()
            %CLOSEALLSERIALCONNECTIONS Summary of this function goes here
            %   Detailed explanation goes here
            insts = instrfindall();
            if(~isempty(insts))
                fclose(insts);
            end
        end
        function resp = checkResponse(str)     
            if(~contains(str{1},'@'))
                disp(str{1})
                error('Did not acknowledge command properly')
            end

            if(contains(str{2},'*'))
                disp(str)
                error('Did not execute command properly')
            end
            
            if(length(str{2})>1)
                resp = str{2}(2:end);
            else
                resp = [];
            end
        end
    end
end
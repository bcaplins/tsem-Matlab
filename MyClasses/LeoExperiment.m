classdef LeoExperiment < handle
    %LEOEXPERIMENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % optional, though recommended
        yag_working_distance_mm
        aperture_id
        shutdown_beam
        
        % if not explicitly set then retrieved from Leo
        working_distance_mm
        beam_voltage_kv
        magnification
        pixel_size_nm
        scan_rot_enable
        scan_rot
        line_integrate_value
        scan_rate_value
        
        
        % if not explicitly set then assumed to be current position
        image_relative_positions
        XYZ_ref
        TR_ref
        use_beamshift
        use_stage
        doStageMove
        
        % assume only se2 unless otherwise stated
        collect_se2
        
        % needed for pSTEM
        mask_filenames
        collect_pSTEM
        
        % required to begin experiment
        filename_prefix
        startIdx
        N_digits
        
        % set after/during experiment
        working_directory
        been_performed
        photo_numbers
        
        exp_start_clock
        exp_end_clock
        
    end
    
    methods
        function obj = LeoExperiment()
            obj.shutdown_beam = logical(0);

            obj.use_beamshift = logical(0);
            obj.use_stage = logical(1);

            obj.collect_se2 = logical(1);

            obj.collect_pSTEM = logical(0);

            obj.scan_rot_enable = logical(0);
           
            obj.doStageMove = logical(0);
            
            obj.been_performed = logical(0);
            
        end
        
        function setRelativePositionsViaGrid(obj,x_dels_um,y_dels_um)
            x_dels = x_dels_um/1000;
            y_dels = y_dels_um/1000;

            [dX dY] = meshgrid(x_dels,y_dels);
            dX = dX';
            dY = dY';

            obj.image_relative_positions = cell(numel(dX),1);
            for idx = 1:numel(dX)
                obj.image_relative_positions{idx} = [-dX(idx) dY(idx) 0];
            end
            obj.doStageMove = logical(1);

        end
        
        function performExperiment(obj,prefix,startIdx,N_digits)
            
            if(nargin<4)
                % prompt user for input
                s = input('Specify filename prefix including _:','s');
                obj.filename_prefix = s;
                
                n = input('Specify starting file index:');
                if(~isfinite(n) || ~isnumeric(n))
                    error('Input an INTEGER!')
                end
                obj.startIdx = n;
                
                n = input('Specify number of digits in filename counter:');
                if(~isfinite(n) || ~isnumeric(n))
                    error('Input an INTEGER!')
                end
                obj.N_digits = n;
                
                fprintf('Press any key to start experiment\n')
                pause
            else
                obj.filename_prefix = prefix;
                obj.startIdx = startIdx;
                obj.N_digits = N_digits;
            end
            
            
            
            
            obj.working_directory = [pwd '\'];
            fprintf('Using current working directory:\n %s \n',obj.working_directory)
            
            obj.been_performed = logical(0);
            obj.photo_numbers = [];
            
            obj.exp_start_clock = clock;
            
            % Set up LEO
            leo = RemCon32Microscope();
            leo.openConnection();
            leo.cmdBeamBlankToggle(1);
            leo.cmdToggleSpecimenCurrentMonitor(0);
            
            % Turn on DMD
            dmd = DMDController();
            dmd.start();


             % if not explicitly set then retrieved from Leo
            if(isempty(obj.working_distance_mm))
                obj.working_distance_mm = leo.queryWorkingDistance();
                fprintf('Using current working distance: %f \n',obj.working_distance_mm)
            else
                fprintf('Setting working distance: %f \n',obj.working_distance_mm)
                leo.cmdWorkingDistance(obj.working_distance_mm);
            end
            
            if(isempty(obj.aperture_id))
                obj.aperture_id = leo.queryAperture();
                fprintf('Current aperture: %f \n',obj.aperture_id)
            end
            
            if(isempty(obj.beam_voltage_kv))
                obj.beam_voltage_kv = leo.queryEHT();
                fprintf('Using current EHT: %f \n',obj.beam_voltage_kv)
            end
             
            if(isempty(obj.magnification))
                obj.magnification = leo.queryMagnification();
                fprintf('Using current magnification: %f \n',obj.magnification)
            else
                fprintf('Setting magnification: %f \n',obj.magnification)
                leo.cmdMag(obj.magnification);
            end
            
            if(isempty(obj.pixel_size_nm))
                obj.pixel_size_nm = leo.queryPixelSize();
                fprintf('Using current pixel size: %f \n',obj.pixel_size_nm)
            end
            
            fprintf('Setting scan rotation enable: %d\n',obj.scan_rot_enable)
            leo.cmdScanRotateToggle(obj.scan_rot_enable);
            if(obj.scan_rot_enable)
                if(isempty(obj.scan_rot))
                    obj.scan_rot = leo.queryScanRotate();
                    fprintf('Using current scan rotation: %f \n',obj.scan_rot)
                else
                    fprintf('Setting scan rotation: %f \n',obj.scan_rot)
                    leo.cmdScanRotate(obj.scan_rot);
                end
            end
            
            if(isempty(obj.line_integrate_value))
                obj.line_integrate_value = 1;
                fprintf('Using current line integrate: %f \n',obj.line_integrate_value)
            else
                fprintf('Will use line integrate: %f \n',obj.line_integrate_value)
            end
            
            if(isempty(obj.scan_rate_value))
                obj.scan_rate_value = leo.queryScanRate();
                fprintf('Using current scan rate: %f \n',obj.scan_rate_value)
            else
                fprintf('Setting scan rate: %f \n',obj.scan_rate_value)
                leo.cmdScanRate(obj.scan_rate_value);
            end
            
            % TODO incorporate beam and stage shift stuff
            if(obj.use_beamshift)
                error('Not implemented yet');
            end
            
            % if not explicitly set then assumed to be current position
            if(isempty(obj.XYZ_ref) || isempty(obj.TR_ref))
                [XYZref TRref] = leo.queryStagePosition();    
                obj.XYZ_ref = XYZref;
                obj.TR_ref = TRref;
                fprintf('Reference position is current position: (%f,%f,%f)\n',obj.XYZ_ref(1),obj.XYZ_ref(2),obj.XYZ_ref(3))
            else
                fprintf('Reference position is user specified: (%f,%f,%f)\n',obj.XYZ_ref(1),obj.XYZ_ref(2),obj.XYZ_ref(3))
            end
            fprintf('Reference angles: (%f,%f)\n',obj.TR_ref(1),obj.TR_ref(2))
                
            if(isempty(obj.image_relative_positions))
                obj.image_relative_positions = {zeros(1,3)};
                fprintf('Using relative position: (0,0,0)\n')
            else
                fprintf('Will attempt to use user-specified stage positions\n')
            end 
            
            
            
            
            
            
            % Determine what images to collect
            if(obj.collect_se2)
                img_idxs = [0];
            end
            if(obj.collect_pSTEM)
                if(isempty(obj.mask_filenames))
                    error('No mask filenames specified')
                end
                num_pSTEM = numel(obj.mask_filenames);
                img_idxs = [img_idxs 1:num_pSTEM];
            end
            
            obj.photo_numbers = zeros(numel(obj.image_relative_positions)*numel(img_idxs),1);
            
            ct = 1;
            % Begin experiment
            for pos_idx = 1:numel(obj.image_relative_positions)
                
                % move stage
                if(obj.doStageMove)
                    xyz = obj.XYZ_ref(:)+obj.image_relative_positions{pos_idx}(:);
                    fprintf('Setting position: (%f,%f,%f)\n',xyz(1),xyz(2),xyz(3))
                    fprintf('Setting angles: (%f,%f)\n',obj.TR_ref(1),obj.TR_ref(2))
                    leo.cmdSetStagePositionSafeish(xyz,obj.TR_ref);
                    pause(5)
                else
                    fprintf('Stage move set to false\n')
                end
                
                % collect images
                for img_idx = img_idxs
                    if(img_idx==0)
                        leo.cmdDetector('SE2');
                    else
                        leo.cmdDetector('Aux 2');
                        dmd.writeFileToDMD(obj.mask_filenames{img_idx});
                    end
                    
                    leo.cmdBeamBlankToggle(0);
                    leo.cmdLineIntegrate(obj.line_integrate_value);
                    
                    
                    isIntegrating = 1;
                    while isIntegrating
                        pause(3)
                        resp = leo.queryIntegrationStatus();
                        fprintf('Integration status: %d\n',resp)

                        if(resp == 0)
                            isIntegrating = 1;
                        else 
                            isIntegrating = 0;
                        end
                    end
                    pause(1)
                    
                    
                    obj.photo_numbers(ct) = leo.cmdRecordImage();
                    ct = ct+1;
                    
                    
                    pause(1)
                    leo.cmdBeamBlankToggle(1);
                    
                end
                
            end
                    
        
            obj.exp_end_clock = clock;
        
            obj.been_performed = logical(1);
            
            % move stage
            if(obj.doStageMove)
                fprintf('Returning to reference position: (%f,%f,%f)\n',obj.XYZ_ref(1),obj.XYZ_ref(2),obj.XYZ_ref(3))
                fprintf('Returning to reference angles: (%f,%f)\n',obj.TR_ref(1),obj.TR_ref(2))
                leo.cmdSetStagePositionSafeish(obj.XYZ_ref,obj.TR_ref);
                pause(1)
            else
                fprintf('Stage move set to false\n')
            end
            
            if(obj.shutdown_beam)
                leo.cmdToggleBeamOnOff(0);
                fprintf('Shutting down EHT (beam)... 2 minute pause...')
                pause(120)
            end
            
            leo.closeAllSerialConnections();
            dmd.writeUpMaskToDMD();
            dmd.stop();
            
            obj.saveExperiment();
                

        end
        
        function saveExperiment(obj)
            if(~obj.been_performed)
                error('Experiment not yet performed')
            end
            
            fstr = ['expt_%s%0.' num2str(obj.N_digits) 'd-%0.' num2str(obj.N_digits) 'd'];
            dirname = sprintf(fstr,obj.filename_prefix,obj.startIdx,obj.startIdx+numel(obj.photo_numbers)-1);
            dirname = [dirname '\'];
            
            % make directory
            [SUCCESS,MESSAGE,MESSAGEID] =  mkdir(dirname);
            if(~SUCCESS)
                error('Failed to make directory');
            end
            
            % move images
            fns = obj.generateFilenames();
            for i=1:numel(fns)
                [SUCCESS,MESSAGE,MESSAGEID] = movefile(fns{i},[dirname fns{i}]);
                if(~SUCCESS)
                    fns{i}
                    [dirname fns{i}]
                    error('Failed to move file');
                end
            end
            
            %copy masks
            for i=1:numel(obj.mask_filenames)
                splits = strsplit(obj.mask_filenames{i},'\');
                [SUCCESS,MESSAGE,MESSAGEID] = copyfile(obj.mask_filenames{i},[dirname splits{end}]);
                if(~SUCCESS)
                    obj.mask_filenames{i}
                    [dirname obj.mask_filenames{i}]
                    error('Failed to move file');
                end
            end
            
            % save mat file            
            fstr = ['expt_%s%0.' num2str(obj.N_digits) 'd-%0.' num2str(obj.N_digits) 'd.mat'];
            fn = sprintf(fstr,obj.filename_prefix,obj.startIdx,obj.startIdx+numel(obj.photo_numbers)-1);
            fprintf('Saving file as: %s\n',fn)
            save([dirname fn],'obj')
        end
        
        function fns = generateFilenames(obj)
            if(~obj.been_performed)
                error('Experiment not yet performed')
            end
            n_imgs = obj.getNumImages();
            fns = cell(n_imgs,1);
            fstr = ['%s%0.' num2str(obj.N_digits) 'd.tif'];
            for i=0:n_imgs-1
                fns{i+1} = sprintf(fstr,obj.filename_prefix,i+obj.startIdx);
            end
        end
        
        function n_tot = getNumImages(obj)
            n_pos = 0;
            n_imgs = 0;
            if(~isempty(obj.image_relative_positions))
                n_pos = numel(obj.image_relative_positions);
            end
            if(~isempty(obj.mask_filenames) && obj.collect_pSTEM)
                n_imgs = numel(obj.mask_filenames);
            end
               
            if(obj.collect_se2)
                n_imgs = n_imgs+1;
            end
            
            n_tot = n_pos*n_imgs;
            
        end
            
        
    end
    
end


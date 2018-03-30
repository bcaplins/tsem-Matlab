classdef DotNetSuperProcess < handle
    
    properties (Constant)
        DO_STDOUT_REDIRECT = logical(1);
        DO_STDERR_REDIRECT = logical(1);
    end
    
    properties
        exe_path;
        dotNETprocess;
        args;
    end
    
    methods
        function obj = DotNetSuperProcess(path,args)
            obj.exe_path = path;
            if (nargin>=2)
                if(~isempty(args))
                    obj.args = args;
                end
            end
       
        end
    end
    
    methods (Access = protected)
        function startProcess(obj)
            proc = System.Diagnostics.Process;
            proc.StartInfo.FileName = obj.exe_path;
            proc.EnableRaisingEvents = true;
            proc.StartInfo.CreateNoWindow = true;
            proc.StartInfo.UseShellExecute = false;
            
            
            proc.StartInfo.RedirectStandardOutput = logical(obj.DO_STDOUT_REDIRECT); %
            proc.StartInfo.RedirectStandardError = logical(obj.DO_STDERR_REDIRECT); %

            if(obj.DO_STDOUT_REDIRECT)
                proc.addlistener('OutputDataReceived',@DotNetSuperProcess.stdOutputHandler); %
            end
            
            if(obj.DO_STDERR_REDIRECT)
                proc.addlistener('ErrorDataReceived',@DotNetSuperProcess.stdErrorHandler); %
            end
            
            proc.StartInfo.RedirectStandardInput = true;
            
            if(~isempty(obj.args))
                proc.StartInfo.Arguments = obj.args;
            end
            
            proc.Start();

            proc.StandardInput.AutoFlush = true;
            
            if(obj.DO_STDOUT_REDIRECT)
                proc.BeginOutputReadLine(); %
            end
            
            if(obj.DO_STDERR_REDIRECT)
                proc.BeginErrorReadLine(); %
            end

            obj.dotNETprocess = proc;            
        end
        
        function endProcess(obj)
            obj.dotNETprocess.StandardInput.WriteLine('');
            obj.dotNETprocess.StandardInput.Close();
            obj.dotNETprocess.WaitForExit();
            obj.dotNETprocess.Close();
        end
        
        function writeToProcess(obj,str)
            strf = strrep(str,'\','\\');
            obj.dotNETprocess.StandardInput.WriteLine(strf);
        end
       
        
    end
    
    methods (Static)
        function stdOutputHandler(dummy, event)
            if(~isempty(event.Data))
                fprintf('STDOUT:    %s\n',char(event.Data))
                
%                 disp('Process stdout:')
%                 disp(event.Data)
            end
        end
        function stdErrorHandler(dummy, event)
            if(~isempty(event.Data))
                fprintf('STDERR:    %s\n',char(event.Data))
%                 disp('Process stderr:')
%                 disp(event.Data)
            end
        end
    end
    
end


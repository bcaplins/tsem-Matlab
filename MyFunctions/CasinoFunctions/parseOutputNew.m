function dat = parseOutputNew(fn,N_SCAN_PTS,N_TRAJ,OPTS)

%  Assumes
% scan point options X,Y,Init Energy
% Collision Options X,Y,Z,E,Coll Type, Reg ID, Rx,Ry,Rz
% Collision Type Options Collision with Regions
% All trajectories


% N_TRAJ = 50000;
% N_SCAN_PTS = 1;
% fn = 'SiN10nm.dat';


% file = textread(fn , '%s', 'delimiter', '\n');
fid = fopen(fn);
file = textscan(fid , '%s', 'delimiter', '\n');

file = file{1};

ln_idx = 1;

% Remove overall header lines
ln_idx = ln_idx+10;

% "================================================================="
% "WinCasino 3.3.0.4"
% "================================================================="
% "Regions Info : "
% =================================================================
% "Name"		Box_0 Inside	Box_0 Outside	Sphere_0 Inside	Sphere_0 Outside
% =================================================================
% "================================================================="
% "initial energy"	30
% "-----------------------------------------------------------------"


dat = cell(N_SCAN_PTS,1);

for sc_idx=1:N_SCAN_PTS
    % Remove scan point headers
    ln_idx = ln_idx+11;
    
%     "================================================================="
%     "Scan Point"	0
%     "================================================================="
%     "X"	-44.7389
%     "Y"	-1.00624
%     "Initial Energy"	30
%     "-----------------------------------------------------------------"
%     "##################################################################"
%     "Scan Point"	0	" Trajectories : "
%     "##################################################################"
%     "-----------------------------------------------------------------"
    
    X = zeros(N_TRAJ,7);
    
    for traj_idx=1:N_TRAJ
        
        isSimple = 0;

        if(OPTS == 1)
            % I think this option is for when 'All trajectories' is
            % selected
            % Remove traj+blank headers
            ln_idx = ln_idx+2;


            % Remove type header
            ln_idx = ln_idx+1;
            
            scat_type = file{ln_idx};
            ln_idx = ln_idx+1;
            
            if strcmp(scat_type,'Backscattered')
            elseif strcmp(scat_type,'Transmitted')
            elseif strcmp(scat_type,'Simple')
                isSimple = 1;
            else
                scat_type
                traj_idx
                error('Unknow traj type')
            end

            %remove remaining header
            ln_idx = ln_idx+4;
        end
        if(OPTS == 0)
            %remove remaining header
            ln_idx = ln_idx+5;
        end

        % Loop through exit point for electron
        
        while 1
            ln = file{ln_idx};
            ln_idx = ln_idx+1;
            
            if(traj_idx==N_TRAJ)
                if(strcmp(ln,'"##################################################################"'))
                    break
                end            
            end
            
            if strcmp(ln,'"-----------------------------------------------------------------"')
                break
            end
            
            tmp = ln;
            
        end
        
        nums = sscanf(tmp,'%f%f%f%f%f%f%f%*s%d');
        if(length(nums) ~= 8)
            error('Wrong number of columns found')
        end

        X(traj_idx,1:7) = nums(1:7);
        if(isSimple)
            % if the electron is simple assume it is absorbed
            X(traj_idx,4:7) = [0 0 0 0];
        end

        
        if(mod(traj_idx,10000)==0)
            sprintf('Traj %d of %d complete',traj_idx,N_TRAJ)
        end

      
    end
    dat{sc_idx} = X;

    sprintf('Scan point %d of %d complete',sc_idx,N_SCAN_PTS)
    
end

fclose(fid);

disp('DONE')





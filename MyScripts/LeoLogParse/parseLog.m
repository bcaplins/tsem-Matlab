fn = 'EM Server_medold.log';
fid = fopen(fn,'rt');
X = textscan(fid,'%s','Delimiter','\r\n');
fclose(fid);

X = X{1};

ivals = [];
ts = [];
ds = [];

for i=1:length(X)
    if(isempty(X{i}))
        continue;
    else
        td = X{i}(1:19);
        if(contains(X{i},'Data not loaded'))
            continue;
        else
%             td = textscan(td,'%{HH:mm:ss}D %{dd-MM-yyyy}D');
            td = textscan(td,'%q %{dd-MM-yyyy}D');
            msg = X{i}(24:end);
            if(contains(msg,'Ext I Monitor'))
                if(contains(msg,'kV'))
                    continue
                else
                    ival = sscanf(msg(16:end),'%f,%s');
                    if(ival>1)
%                         ts = [ts td{1}];
                        ds = [ds td{2}];
                        ivals = [ivals ival];
                    end
                end
            end
        end
    end
end

figure
plot(ds,ivals)




function closeallopen()

    handles=findall(groot,'type','figure')

    for i=1:length(handles)
        figure(handles(i).Number)
        clf 
    end

end
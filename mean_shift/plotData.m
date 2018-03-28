function plotData(data, labels, data_mean)

[~,nDims] = size(data);
if (nDims>3)
   error('Data dimension should be less than 3')
end

nLabels = max(labels);
color = 'gmcybcmcmgckmy';
marker= '....<^phx+sd<^x+sd<^';

myMean_ = data_mean;
if nDims == 2
    figure, hold on,
    for i = 1:nLabels
        myData_ = data( labels == i, 1:2 );
        plot(myData_(:,1), myData_(:,2),[color(i) marker(i)]), hold on
        
        plot(myMean_(i,1),myMean_(i,2),'s','MarkerEdgeColor', ...
                                   'k','MarkerFaceColor',color(i), ...
                                       'MarkerSize',10), hold on    
    end
    % - plot outliers
    myData_ = data( labels == 0, 1:2 );
    title ('ground truth: outliers are x(black)')
    plot(myData_(:,1), myData_(:,2),'xk'), hold on,
    daspect([1 1 1]),axis square, hold off
else 
    figure, hold on,
    for i = 1:nLabels
        myData_ = data(labels == i, 1:3);
        plot3(myData_(:,1), myData_(:,2),myData_(:,3),[color(i) marker(i)]), hold on,
        
        plot3(myMean_(i,1),myMean_(i,2),myMean_(i,3),'s','MarkerEdgeColor', ...
                                               'k','MarkerFaceColor',color(i), ...
                                               'MarkerSize',10),hold on
    end
    myData_ = data(labels == 0, 1:3);
    title ('ground truth: outliers are x(black)')
    plot3(myData_(:,1), myData_(:,2),myData_(:,3),'xk'), hold on,
    daspect([1 1 1]),axis square, hold off
end
 
 
        
        
        
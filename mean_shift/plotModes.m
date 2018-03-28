function [source_means, modes, modes_pr] = plotModes()

clc, close all,

nPts    = 700;
nDims   = 3;
nLabels = 3;
nSeeds  = 16;
dTol    = 0.1;

color = 'grmcygcrmcmrgyrgckmy';
marker= 'xxxxxxxxxxphx+sd<^x+sd<^';

[points, pt_label, source_means] = generateData( nDims,  ...
                                                 nPts,   ...
                                                 nLabels);
plotData(points, pt_label, source_means)

i = 1;
figure,
if nDims == 2
    tic,
    [modes,modes_pr,labels] = findModes(points, nSeeds, dTol);
    toc,
    
    nClusters   = size(modes,1);
    while (i <= nClusters)
        
        plot(points(labels == i,1), points(labels == i,2), ...
                                [color(i) marker(i)]), 
        hold on
        plot(modes(i,1), modes(i,2),'o','MarkerEdgeColor','k', ...
                                      'MarkerFaceColor',color(i), ...
                                      'MarkerSize',10), 
        hold on,
        i = i+1;
    end
    title ('meanshift modes')
    daspect([1 1 1]),axis square
elseif nDims == 3
    tic,
    [modes,modes_pr,labels] = findModes(points, nSeeds, dTol);
    toc,
    
    nClusters   = size(modes,1);
    while (i <= nClusters)
       
       plot3(points(labels == i,1), points(labels == i,2), ...
             points(labels == i,3),[color(i) marker(i)]), 
       hold on
       plot3(modes(i,1), modes(i,2),modes(i,3), 'o','MarkerEdgeColor','k', ...
                                           'MarkerFaceColor',color(i), ...
                                           'MarkerSize',10), 
       hold on,
       i = i+1;
    end 
   title ('meanshift modes')
   daspect([1 1 1]),axis square
else
    error('Number of dims should be <= 3!')
end
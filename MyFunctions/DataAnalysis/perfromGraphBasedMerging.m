function [outputArg1,outputArg2] = perfromGraphBasedMerging(dat,filledDat,isGood,spSegs)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

% Do graph based merging

% Mask off the bad data and determine averages
for i=1:size(dat,3)
    tmp = dat(:,:,i);
    tmp(~isGood) = NaN;
    dat(:,:,i) = tmp;
end


L = double(spSegs+1);

outputImage = zeros(size(dat),'like',dat);
idx = label2idx(L);

numLabels = numel(idx);
numRows = size(dat,1);
numCols = size(dat,2);
numPix = numRows*numCols;
numDims = size(dat,3);

mean_values = zeros(numLabels,numDims);
centroids = zeros(numLabels,2);

[XXX,YYY] = meshgrid(1:size(img,2),1:size(img,1));
for labelVal = 1:numLabels
    for id = 1:numDims
        chanIdx = idx{labelVal} + (id-1)*numPix;
        mean_values(labelVal,id) = mean(dat(chanIdx),'omitnan');
        if(~isfinite(mean_values(labelVal,id)))
            mean_values(labelVal,id) = mean(filledDat(chanIdx),'omitnan');
        end
        outputImage(chanIdx) = mean_values(labelVal,id);
    end
    centroids(labelVal,1) = mean(XXX(idx{labelVal}));
    centroids(labelVal,2) = mean(YYY(idx{labelVal}));
end    



g = adjacentRegionsGraph(L,4);



g.Nodes.PixelList = cell(g.numnodes,1);
g.Nodes.MeanValues = zeros(g.numnodes,size(dat,3));
g.Nodes.NumPix = zeros(g.numnodes,1);
% g.Nodes.NumPixLists = ones(g.numnodes,1);
for n_idx=1:g.numnodes
    label = g.Nodes.Label(n_idx);
    g.Nodes.PixelList(n_idx) = idx(label);
    g.Nodes.MeanValues(n_idx,:) = mean_values(label,:);
    g.Nodes.NumPix(n_idx) = numel(idx{label});
end



g.Edges.Weight = zeros(length(g.Edges.Labels),1);


for e_idx = 1:g.numedges
    % These are labels in idx structure
    node_labels = g.Edges.Labels(e_idx,:);
    
%     % These are labels in graph node structure
%     g.Edges.EndNodes(e_idx,:);
    
    % Retrieve pixel data
    A = mean_values(node_labels(1),:);
    B = mean_values(node_labels(2),:);
    
    % Compute distance and set as edge weight
    g.Edges.Weight(e_idx) = vecnorm(A-B,2,2);
end


Cdat = convertHyperspectralImageToHSVimage(outputImage,1);

figure(314211)
clf
imshow(Cdat)





starts = round(ginput());
starts_label = zeros(size(starts,1),1);
starts_nodeIDs = zeros(size(starts,1),1);
for i=1:size(starts)
    starts_label(i) = L(starts(i,2),starts(i,1));
    starts_nodeIDs(i) = find(g.Nodes.Label == starts_label(i));
    viscircles(starts(i,:),10)

    
end



counter_var = 0;
while 1
    counter_var = counter_var + 1;
    tic
    % Find all nodes connected to start nodes
    nns = [];
    ref_node = [];
    for i=1:size(starts,1)
        tmp = neighbors(g,starts_nodeIDs(i))';
        nns = [nns tmp];
        ref_node = [ref_node starts_nodeIDs(i)*ones(size(tmp))];
    end
    
    
    % Find the shortest edge that is not connecting two start nodes
%     pos_edges = zeros(size(nns));
%     for i=1:length(nns)
%         edge_idx = g.findedge(nns(i),ref_node(i));
%         pos_edges(i) = g.Edges.Weight(edge_idx);
%     end
    edge_idx = g.findedge(nns,ref_node);
    pos_edges = g.Edges.Weight(edge_idx);
    

    [pos_edges_sorted,sortedIdxs] = sort(pos_edges);
    curr_subidx = -1;
    for i=1:length(sortedIdxs)
        tmp = sortedIdxs(i);
        if(ismember(nns(tmp),starts_nodeIDs))
            continue
        else
            curr_subidx = tmp;
            break;
        end
    end
    if(curr_subidx == -1)
        break
    end
    
    % Combine the nodes:
    % Find all neighbors of new node
    node_merged = nns(curr_subidx);
    node_ref = ref_node(curr_subidx);
    
    % move pixel lists over
    g.Nodes.PixelList{node_ref} = [g.Nodes.PixelList{node_ref}; g.Nodes.PixelList{node_merged}];
%     g.Nodes.PixelList{node_ref}(g.Nodes.NumPix(node_ref)+(1:g.Nodes.NumPix(node_merged))) = g.Nodes.PixelList{node_merged};
%     g.Nodes.PixelList(node_ref,g.Nodes.NumPixLists(node_ref)) = g.Nodes.PixelList(node_merged);
%     g.Nodes.NumPixLists(node_ref) = g.Nodes.NumPixLists(node_ref)+1;
    
    
    % recompute node values
    g.Nodes.MeanValues(node_ref,:) = ...
    (g.Nodes.NumPix(node_ref)*g.Nodes.MeanValues(node_ref,:) + ...
        g.Nodes.NumPix(node_merged)*g.Nodes.MeanValues(node_merged,:))/ ...
        (g.Nodes.NumPix(node_ref)+g.Nodes.NumPix(node_merged));

    g.Nodes.NumPix(node_ref) = g.Nodes.NumPix(node_ref) + g.Nodes.NumPix(node_merged);
    
    g.Nodes.NumPix(node_merged) = 0;
    g.Nodes.MeanValues(node_merged,:) = 0;
    g.Nodes.PixelList{node_merged} = [];
    
    nns_to_move = g.neighbors(node_merged);
    
    
    
    % move edges to ref node    
    isLoop = (node_ref == nns_to_move);
    nns_to_move = nns_to_move(~isLoop);
    
    if(~isempty(nns_to_move))
    
        node_refs = repmat(node_ref,size(nns_to_move));
        curr_edges = g.findedge(node_refs,nns_to_move);
        
        
        edge_weights = vecnorm(g.Nodes.MeanValues(node_refs,:)-g.Nodes.MeanValues(nns_to_move,:),2,2);
        
        edgeExists = (curr_edges~=0);
        if(~isempty(edge_weights(edgeExists)))
            g.Edges.Weight(curr_edges(edgeExists)) = edge_weights(edgeExists);
        end
        g = g.addedge(node_refs(~edgeExists),nns_to_move(~edgeExists),...
            edge_weights(~edgeExists));
        
        
    
    end
    
    g = g.rmedge([nns_to_move; node_merged],[repmat(node_merged,size(nns_to_move)); node_ref]);
    
%     for i=length(nns_to_move):-1:1
%         % Remove old 
%         g = g.rmedge(nns_to_move(i),node_merged);
%         
%         if(nns_to_move(i) == node_ref)
%             continue
%         end
%         curr_edge = g.findedge(node_ref,nns_to_move(i));
%         if(curr_edge == 0)
%             g = g.addedge(node_ref,nns_to_move(i),...
%                 pdist2(g.Nodes.MeanValues(node_ref,:),g.Nodes.MeanValues(nns_to_move(i),:)));
%         else
%             g.Edges.Weight(curr_edge) = pdist2(g.Nodes.MeanValues(node_ref,:),g.Nodes.MeanValues(nns_to_move(i),:));
%         end
%     end    
    
    if(mod(counter_var,100) == 0)
%         g
%         figure(9832)
%         clf
%         hold on
%         h = plot(g,'XData',centroids(:,1),'YData',centroids(:,2))
%         axis ij
        g
    end
    
    toc
end

% figure(9832)
% clf
% hold on
% h = plot(g,'XData',centroids(:,1),'YData',centroids(:,2))
% axis ij





for i=g.numnodes:-1:1
    if(g.Nodes.NumPix(i) == 0)
        g = g.rmnode(i);
    end
end


[dummy sidxs] = sort(starts_label);



n_idxs = find(g.Nodes.NumPix>0);




dat= dat;

outputImage = zeros(size(dat),'like',dat);

numLabels = numel(n_idxs);
numRows = size(dat,1);
numCols = size(dat,2);
numPix = numRows*numCols;

numDims = size(dat,3);

mean_values = zeros(numLabels,numDims);

for labelVal = 1:numLabels
%     gidxs = find(isGood);
    for id = 1:numDims
%         chanIdx = intersect(g.Nodes.PixelList{n_idxs(labelVal)},gidxs) + (id-1)*numPix;
        chanIdx = g.Nodes.PixelList{n_idxs(labelVal)} + (id-1)*numPix;
        mean_values(labelVal,id) = mean(dat(chanIdx));
        outputImage(chanIdx) = mean_values(labelVal,id);
    end
end    



Cdat = convertHyperspectralImageToHSVimage(outputImage,1);

figure(314211)
clf
imshow(Cdat)

% Cdat = convertHyperspectralImageToHSVimage(img,1);
% 
% figure(314212)
% clf
% imshow(Cdat)




figure(12312)
plot(mean_values')


figure(4321)
clf

x = [1:20]'*3-3
fittedAngs = [];
fittedAmps = [];
for i=1:size(mean_values,1)
    
    
    y = mean_values(i,:)';
    [sy si] = max(y);
    [sb dummy] = min(y);
    startPoints = [sy-sb x(si) 2 sb 2e-4];
    gaussEqn = 'a*exp(-(((x-b)/(sqrt(2)*c))^2))+d*x+e';
    f1 = fit(x,y,gaussEqn,'Start', startPoints);
    
    subplot(1,2,1)
    plot(x,y,'o--',x,f1(x),'r-')
%         ylim([0.03 0.12])
    hold on
    subplot(1,2,2)
    hold on
    plot(f1.b*[1 1],[0 max(N)],'k')
    ci = confint(f1);
    plot(ci(1,2)*[1 1],[0 max(N)],'k--')
    plot(ci(2,2)*[1 1],[0 max(N)],'k--')
    xlim([0 60])
    fittedAngs = [fittedAngs f1.b];
    f1
%     pause
end

g.Nodes.Angles = fittedAngs';

g.Edges.Misorientation = zeros(size(g.Edges.Weight));
for i=1:g.numedges
    node_ids = g.Edges.EndNodes(i,:);
    g.Edges.Misorientation(i) = abs(g.Nodes.Angles(node_ids(1))-g.Nodes.Angles(node_ids(2)));
end
    

fittedAngs'






figure(314213)
clf
imshow(Cdat.*se2)


tmp = reshape(dat,[size(dat,1)*size(dat,2) size(dat,3)]);

baselines = computeBaselines(dat);

maxes = reshape(max(tmp,[],2),[size(dat,1) size(dat,2)]);

figure(1232131)
clf
imshow((maxes-baselines)*4)




end

